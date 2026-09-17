import { assert, assertEquals } from "@std/assert";
import { handler } from "../../supabase/functions/ingest-material/handler.ts";
import { admin, createTestSchool } from "./harness.ts";

const RUN = Deno.env.get("RUN_MODEL_TESTS") === "1";

const SAMPLE = `Chapter 1: Quadratic Equations

A quadratic equation has the form ax^2 + bx + c = 0 where a is not zero.

Factorisation: write x^2 + 5x + 6 = 0 as (x+2)(x+3) = 0, so x = -2 or x = -3.

The quadratic formula: x = (-b +/- sqrt(b^2 - 4ac)) / 2a.

The discriminant b^2 - 4ac tells us how many real roots exist:
positive means two, zero means one, negative means none.

Worked example: solve 2x^2 - 7x + 3 = 0 using the formula.
a = 2, b = -7, c = 3. The discriminant is 49 - 24 = 25.
x = (7 +/- 5) / 4, so x = 3 or x = 0.5.`;

/// A minimal single-page PDF holding the sample text, built by hand so the
/// test has no dependency on the content-authoring pipeline.
function samplePdf(): Uint8Array {
  const lines = SAMPLE.split("\n").map((line) =>
    `(${line.replace(/[()\\]/g, "")}) Tj 0 -14 Td`
  ).join("\n");
  const content = `BT /F1 10 Tf 40 800 Td\n${lines}\nET`;
  const objects = [
    "<< /Type /Catalog /Pages 2 0 R >>",
    "<< /Type /Pages /Kids [3 0 R] /Count 1 >>",
    "<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] " +
      "/Resources << /Font << /F1 5 0 R >> >> /Contents 4 0 R >>",
    `<< /Length ${content.length} >>\nstream\n${content}\nendstream`,
    "<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>",
  ];

  let pdf = "%PDF-1.4\n";
  const offsets: number[] = [];
  objects.forEach((object, index) => {
    offsets.push(pdf.length);
    pdf += `${index + 1} 0 obj\n${object}\nendobj\n`;
  });
  const xref = pdf.length;
  pdf += `xref\n0 ${objects.length + 1}\n0000000000 65535 f \n`;
  for (const offset of offsets) {
    pdf += `${offset.toString().padStart(10, "0")} 00000 n \n`;
  }
  pdf += `trailer\n<< /Size ${objects.length + 1} /Root 1 0 R >>\n` +
    `startxref\n${xref}\n%%EOF`;

  return new TextEncoder().encode(pdf);
}

async function seedMaterial(school: Awaited<ReturnType<typeof createTestSchool>>) {
  const db = admin();
  const subjectId = crypto.randomUUID();
  const chapterId = crypto.randomUUID();
  const materialId = crypto.randomUUID();
  const path = `${school.id}/${materialId}.pdf`;

  await db.from("subjects").insert({
    id: subjectId, school_id: school.id, name: "Mathematics", chapter_count: 1,
  });
  await db.from("chapters").insert({
    id: chapterId, school_id: school.id, subject_id: subjectId,
    ordinal: 1, title: "Quadratic Equations",
  });
  await db.storage.from("materials").upload(
    path,
    new Blob([samplePdf() as unknown as BlobPart], { type: "application/pdf" }),
    { contentType: "application/pdf" },
  );
  await db.from("materials").insert({
    id: materialId, school_id: school.id, chapter_id: chapterId,
    uploaded_by: school.teacher.id, storage_path: path,
    mime_type: "application/pdf", original_filename: "ch1.pdf",
  });

  return { chapterId, materialId, path };
}

async function runStage(token: string, materialId: string) {
  const response = await handler(
    new Request("http://local/ingest-material", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${token}`,
        "content-type": "application/json",
      },
      body: JSON.stringify({ materialId }),
    }),
  );
  return { status: response.status, body: await response.json() };
}

Deno.test({
  name: "ingestion produces a bounded, locked micro-skill set and a valid pool",
  ignore: !RUN,
  fn: async () => {
    const school = await createTestSchool("ingest");
    const { chapterId, materialId, path } = await seedMaterial(school);
    const { data: session } = await school.teacher.client.auth.getSession();
    const token = session.session!.access_token;

    try {
      // ── stage 1: pack + micro-skills ──
      const first = await runStage(token, materialId);
      assertEquals(first.status, 200);
      assertEquals(first.body.status, "pack_ready");

      const { data: skills } = await admin()
        .from("micro_skills").select("slug").eq("chapter_id", chapterId);
      assert(
        skills!.length >= 5 && skills!.length <= 8,
        `expected 5-8 micro-skills, got ${skills!.length}`,
      );
      const slugs = skills!.map((s) => s.slug);
      assertEquals(new Set(slugs).size, slugs.length, "slugs must be unique");

      const { data: chapter } = await admin()
        .from("chapters").select("micro_skills_locked_at").eq("id", chapterId).single();
      assert(chapter!.micro_skills_locked_at !== null, "the set must be locked");

      // ── stage 2: the pool (one difficulty band per invocation) ──
      let poolStatus = first.body.status;
      for (let i = 0; i < 5 && poolStatus !== "pool_ready"; i++) {
        const step = await runStage(token, materialId);
        assertEquals(step.body.stage, "pool");
        assert(
          step.body.status === "pack_ready" || step.body.status === "pool_ready",
          `unexpected pool status: ${step.body.status}`,
        );
        poolStatus = step.body.status;
      }
      assertEquals(poolStatus, "pool_ready", "pool did not complete within 5 invocations");

      const { data: questions } = await admin()
        .from("questions")
        .select("micro_skill_id, difficulty, options, correct_index, provenance")
        .eq("chapter_id", chapterId);

      assert(questions!.length >= 40, `pool too small: ${questions!.length}`);
      assert(
        questions!.every((q) => q.provenance === "pool"),
        "ingestion produces shared pool items only",
      );
      assert(
        questions!.every((q) => q.difficulty >= 1 && q.difficulty <= 3),
        "every item must fall in a band",
      );
      assert(
        questions!.every((q) =>
          q.correct_index >= 0 && q.correct_index < (q.options as string[]).length
        ),
        "correct_index must address a real option",
      );

      const bands = new Set(questions!.map((q) => q.difficulty));
      assertEquals(bands.size, 3, "all three bands must be represented");

      // ── stage 3: explanations ──
      const third = await runStage(token, materialId);
      assertEquals(third.body.status, "ready");

      const { data: allExplanations } = await admin()
        .from("micro_skill_explanations").select("micro_skill_id, body")
        .eq("school_id", school.id);
      assertEquals(
        allExplanations!.length, skills!.length,
        "one explanation per micro-skill -- these power offline targeted notes",
      );
      assert(allExplanations!.every((e) => e.body.length > 40));

      // ── re-ingestion must not widen the vocabulary ──
      await admin().from("materials")
        .update({ ingestion_status: "pending" }).eq("id", materialId);
      await runStage(token, materialId);

      const { data: after } = await admin()
        .from("micro_skills").select("slug").eq("chapter_id", chapterId);
      assertEquals(
        after!.length, skills!.length,
        "re-ingesting the same document must not add a slug",
      );
    } finally {
      await admin().storage.from("materials").remove([path]);
      await school.dispose();
    }
  },
});

Deno.test("a student's token cannot trigger ingestion", async () => {
  const school = await createTestSchool("ingest-forbidden");
  try {
    const { data: session } = await school.student.client.auth.getSession();
    const result = await runStage(
      session.session!.access_token,
      crypto.randomUUID(),
    );
    assertEquals(result.status, 403);
  } finally {
    await school.dispose();
  }
});
