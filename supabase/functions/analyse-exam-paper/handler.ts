import {
  type Caller,
  isServiceRoleBearer,
  requireCaller,
  requireRole,
  serviceClient,
} from "../_shared/auth.ts";
import { GeminiClient } from "../_shared/gemini.ts";
import { guarded, HttpError, json } from "../_shared/http.ts";
import { examAnalysisSchema } from "../_shared/schemas.ts";

const MAX_ATTEMPTS = 3;

/// A transient upstream-capacity error must not consume the paper's retry
/// budget or mark it failed — same rule as ingestion. These are the exact
/// strings GeminiClient produces on 429/5xx and rotation exhaustion.
function isTransientQuotaError(msg: string): boolean {
  return /rate limited|exhausted/i.test(msg);
}

function toBase64(bytes: Uint8Array): string {
  let binary = "";
  for (const byte of bytes) binary += String.fromCharCode(byte);
  return btoa(binary);
}

export const handler = guarded(async (req: Request): Promise<Response> => {
  if (req.method !== "POST") throw new HttpError(405, "method_not_allowed");

  // The cron sweep authenticates as the service role and has no profile. Try
  // the normal caller path first; fall back only for a verified service_role
  // bearer.
  const authorization = req.headers.get("Authorization");
  let caller: Caller | null = null;
  try {
    caller = await requireCaller(req);
    requireRole(caller, "teacher", "admin");
  } catch (err) {
    if (!isServiceRoleBearer(authorization)) throw err;
  }

  const { examPaperId } = await req.json().catch(() => ({}));
  if (typeof examPaperId !== "string") throw new HttpError(400, "exam_paper_id_required");

  const db = serviceClient();
  let query = db
    .from("exam_papers")
    .select("*, chapters(id, title, subjects(name))")
    .eq("id", examPaperId);
  if (caller) query = query.eq("school_id", caller.schoolId);
  const { data: paper } = await query.maybeSingle();
  if (!paper) throw new HttpError(404, "exam_paper_not_found");
  if (paper.analysis_status === "analysed") {
    return json({ status: "already_analysed" });
  }

  const schoolId = paper.school_id as string;
  const chapter = paper.chapters as Record<string, unknown>;
  const chapterId = chapter.id as string;

  const { data: skills } = await db
    .from("micro_skills")
    .select("id, slug, label, description")
    .eq("chapter_id", chapterId)
    .order("ordinal");
  if (!skills?.length) throw new HttpError(409, "chapter_has_no_micro_skills");
  const slugs = skills.map((s) => s.slug as string);
  const idBySlug = new Map(skills.map((s) => [s.slug as string, s.id as string]));

  try {
    const { data: file, error: downloadError } = await db.storage
      .from("exam-papers")
      .download(paper.storage_path as string);
    if (downloadError || !file) throw new Error(`could not read paper: ${downloadError?.message}`);
    const bytes = new Uint8Array(await file.arrayBuffer());
    const mimeType = file.type && file.type !== "" ? file.type : "application/pdf";

    const gemini = GeminiClient.fromEnvironment();
    const { skills: results } = await gemini.generateJson<{
      skills: { micro_skill: string; questions_seen: number; questions_wrong: number }[];
    }>({
      prompt: [
        `This is a marked exam paper for the chapter "${chapter.title}"`,
        `(Malaysian Form 4). For each micro-skill below that the paper tests,`,
        `report how many marks/questions the student attempted on it and how`,
        `many they got wrong, reading the marker's annotations.`,
        ``,
        ...skills.map((s) => `- ${s.slug}: ${s.label} -- ${s.description}`),
        ``,
        `Only use these slugs. Omit a micro-skill the paper does not test.`,
      ].join("\n"),
      schema: examAnalysisSchema(slugs),
      temperature: 0.2,
      files: [{ mimeType, data: toBase64(bytes) }],
    });

    const rows = results
      .filter((r) => idBySlug.has(r.micro_skill) && r.questions_seen > 0)
      .map((r) => {
        const wrong = Math.max(0, Math.min(r.questions_wrong, r.questions_seen));
        return {
          id: crypto.randomUUID(),
          school_id: schoolId,
          student_id: paper.student_id as string,
          micro_skill_id: idBySlug.get(r.micro_skill)!,
          weight: Number((wrong / r.questions_seen).toFixed(4)),
          source: "exam" as const,
        };
      });

    if (rows.length > 0) {
      // Keyed (student, micro_skill, source): an exam row never overwrites the
      // quiz row on the same skill, and a re-analysis replaces the prior exam
      // figure rather than duplicating it.
      const { error } = await db
        .from("weaknesses")
        .upsert(rows, { onConflict: "student_id,micro_skill_id,source" });
      if (error) throw new Error(`weakness upsert failed: ${error.message}`);
    }

    await db
      .from("exam_papers")
      .update({
        analysis_status: "analysed",
        analysis_note: `${rows.length} micro-skill(s) scored`,
        attempts: (paper.attempts as number) + 1,
      })
      .eq("id", examPaperId);

    return json({ status: "analysed", weaknessRows: rows.length });
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    if (isTransientQuotaError(message)) {
      // Leave it pending; the sweep retries without spending the budget.
      return json({ status: "deferred", reason: "upstream_capacity" }, 503);
    }
    const attempts = (paper.attempts as number) + 1;
    await db
      .from("exam_papers")
      .update({
        analysis_status: attempts >= MAX_ATTEMPTS ? "failed" : "pending",
        analysis_note: message.slice(0, 300),
        attempts,
      })
      .eq("id", examPaperId);
    throw new HttpError(502, "analysis_failed", message);
  }
});
