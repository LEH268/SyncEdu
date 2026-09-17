import { createClient } from "@supabase/supabase-js";

const url = Deno.env.get("SUPABASE_URL")!;
const service = createClient(url, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!, {
  auth: { persistSession: false },
});

const SUBJECTS: Record<string, string[]> = {
  Mathematics: [
    "Quadratic Functions and Equations",
    "Number Bases",
    "Logical Reasoning",
    "Operations on Sets",
    "Network in Graph Theory",
  ],
  Biology: [
    "Cell Biology and Cell Organisation",
    "Movement of Substances Across the Plasma Membrane",
    "Chemical Composition in a Cell",
    "Metabolism and Enzymes",
    "Nutrition",
  ],
};

// Robust school lookup: seed_demo_school.ts has historically been run more than
// once, leaving duplicate "SMK Demo" rows. Prefer the newest row that actually
// has a teacher profile rather than assuming exactly one exists.
const { data: schools, error: schoolErr } = await service
  .from("schools").select("id, created_at").eq("name", "SMK Demo")
  .order("created_at", { ascending: false });
if (schoolErr) throw schoolErr;
if (!schools?.length) throw new Error("run scripts/seed_demo_school.ts first");

let school: { id: string } | undefined;
let teacher: { id: string } | undefined;
for (const candidate of schools) {
  const { data: t } = await service
    .from("profiles").select("id")
    .eq("school_id", candidate.id).eq("role", "teacher")
    .limit(1).maybeSingle();
  if (t) {
    school = { id: candidate.id };
    teacher = { id: t.id };
    break;
  }
}
if (!school || !teacher) {
  throw new Error(
    "no SMK Demo school has a teacher profile; run scripts/seed_demo_school.ts",
  );
}
console.log(`using school ${school.id}, teacher ${teacher.id}`);

// Driven with the demo teacher's JWT; the deployed handler also accepts the
// service-role bearer (used by the cron sweep). The handler accepts a
// teacher/admin caller. Tokens last an hour; refresh once per chapter to stay
// well inside that.
const TEACHER_EMAIL = "teacher@demo.syncedu.invalid";
const TEACHER_PASSWORD = "SyncEdu-Demo-1!";
const authClient = createClient(
  url,
  Deno.env.get("SUPABASE_ANON_KEY")!,
  { auth: { persistSession: false } },
);
async function teacherToken(): Promise<string> {
  const { data, error } = await authClient.auth.signInWithPassword({
    email: TEACHER_EMAIL,
    password: TEACHER_PASSWORD,
  });
  if (error || !data.session) {
    throw new Error(`teacher sign-in failed: ${error?.message}`);
  }
  return data.session.access_token;
}

for (const [subjectName, chapters] of Object.entries(SUBJECTS)) {
  const subjectId = crypto.randomUUID();
  // Idempotent: reuse an existing subject of this name for the school.
  const { data: existingSubject } = await service
    .from("subjects").select("id").eq("school_id", school.id)
    .eq("name", subjectName).maybeSingle();
  const effectiveSubjectId = existingSubject?.id ?? subjectId;
  if (!existingSubject) {
    await service.from("subjects").insert({
      id: effectiveSubjectId,
      school_id: school.id,
      name: subjectName,
      chapter_count: chapters.length,
    });
  }

  for (const [index, title] of chapters.entries()) {
    const folder = subjectName.toLowerCase();
    const local = `content/pdf/${folder}-ch${index + 1}.pdf`;

    // Reuse an existing chapter at this (subject, ordinal), else create one.
    const { data: existingChapter } = await service
      .from("chapters").select("id")
      .eq("subject_id", effectiveSubjectId).eq("ordinal", index + 1)
      .maybeSingle();
    const chapterId = existingChapter?.id ?? crypto.randomUUID();
    if (!existingChapter) {
      await service.from("chapters").insert({
        id: chapterId,
        school_id: school.id,
        subject_id: effectiveSubjectId,
        ordinal: index + 1,
        title,
      });
    }

    // Reuse an existing material for this chapter, else upload + create one.
    const { data: existingMaterial } = await service
      .from("materials").select("id, ingestion_status")
      .eq("chapter_id", chapterId).order("created_at").limit(1).maybeSingle();
    let materialId: string;
    let status: string;
    if (existingMaterial) {
      materialId = existingMaterial.id as string;
      status = existingMaterial.ingestion_status as string;
    } else {
      materialId = crypto.randomUUID();
      status = "pending";
      const path = `${school.id}/${materialId}.pdf`;
      const bytes = await Deno.readFile(local);
      const { error: uploadError } = await service.storage
        .from("materials").upload(path, bytes, {
          contentType: "application/pdf",
        });
      if (uploadError) throw uploadError;
      await service.from("materials").insert({
        id: materialId,
        school_id: school.id,
        chapter_id: chapterId,
        uploaded_by: teacher.id,
        storage_path: path,
        mime_type: "application/pdf",
        original_filename: `${folder}-ch${index + 1}.pdf`,
      });
    }

    if (status === "ready") {
      console.log(`${subjectName} ch${index + 1}: already ready, skipping`);
      continue;
    }

    // Drive the remaining stages. The function advances one stage per call and
    // is resumable, so re-POSTing the same materialId until it reports "ready"
    // (or repeats a status) is safe. Retry transient edge/Gemini failures.
    const token = await teacherToken();
    // Progress signature: the pool stage keeps status at "pack_ready" across all
    // three difficulty bands, so status alone can't detect real movement. Track
    // (status, stage, band) and only declare a stall when the exact same triple
    // repeats across two consecutive calls with no forward movement.
    let lastSig = `${status}||`;
    let repeats = 0;
    const CALL_CAP = 12;
    for (let call = 0; call < CALL_CAP; call++) {
      const response = await fetch(`${url}/functions/v1/ingest-material`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "apikey": Deno.env.get("SUPABASE_ANON_KEY")!,
          "Authorization": `Bearer ${token}`,
        },
        body: JSON.stringify({ materialId }),
      });
      const result = await response.json().catch(() => ({}));
      console.log(
        `${subjectName} ch${index + 1} call ${call}: ${JSON.stringify(result)}`,
      );
      if (!response.ok) {
        const retryable = response.status >= 500 ||
          result?.code === "WORKER_RESOURCE_LIMIT" ||
          result?.error === "internal_error";
        if (retryable && call < CALL_CAP - 1) {
          await new Promise((r) => setTimeout(r, 20_000));
          continue;
        }
        throw new Error(`ingestion failed for ${subjectName} ch${index + 1}`);
      }
      const next = (result?.status as string) ?? "";
      if (next === "ready") break;
      const stage = (result?.stage as string) ?? "";
      const band = result?.counts?.band ??
        (await service.from("materials").select("pool_bands_done")
          .eq("id", materialId).maybeSingle()).data?.pool_bands_done ??
        "";
      const sig = `${next}|${stage}|${band}`;
      if (sig === lastSig) {
        repeats += 1;
        if (repeats >= 2) {
          throw new Error(
            `ingestion stalled at ${sig} for ${subjectName} ch${index + 1}`,
          );
        }
      } else {
        repeats = 0;
      }
      lastSig = sig;
    }
  }
}

// ── report ──
const { data: report } = await service
  .from("chapters")
  .select("title, micro_skills(slug), questions(id)")
  .eq("school_id", school.id);

for (const chapter of report ?? []) {
  console.log(
    `${chapter.title}: ${(chapter.micro_skills as unknown[]).length} skills, ` +
      `${(chapter.questions as unknown[]).length} questions`,
  );
}
