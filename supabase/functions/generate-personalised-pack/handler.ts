import { requireCaller, serviceClient } from "../_shared/auth.ts";
import { GeminiClient } from "../_shared/gemini.ts";
import { guarded, HttpError, json } from "../_shared/http.ts";
import { questionBatchSchema } from "../_shared/schemas.ts";

const MODEL_VERSION = "gemini-2.5-flash";
const DEFAULT_COUNT = 10;
// At most this many of the pack are steered toward weak skills; the rest stay
// unbiased so the pack still covers the whole chapter.
const MAX_WEAK_SKILLS = 4;

/// Only the student themselves, a teacher of their class, or an admin of
/// their school may request a personalised pack on their behalf. Mirrors
/// `may_read_student` from the activity migration, evaluated here against the
/// already-verified caller rather than via RLS (this function runs with the
/// service role and writes across tables RLS does not expose together).
async function assertMayRequestFor(
  db: ReturnType<typeof serviceClient>,
  caller: { userId: string; schoolId: string; role: string },
  studentId: string,
): Promise<Record<string, unknown>> {
  const { data: student } = await db
    .from("students")
    .select("id, school_id, profile_id, class_id, special_needs")
    .eq("id", studentId)
    .maybeSingle();

  if (!student || student.school_id !== caller.schoolId) {
    throw new HttpError(403, "forbidden");
  }

  const isSelf = student.profile_id === caller.userId;
  const isAdmin = caller.role === "admin";
  let isTeachingClass = false;
  if (!isSelf && !isAdmin && caller.role === "teacher" && student.class_id) {
    const { data: teaches } = await db
      .from("class_subjects")
      .select("id")
      .eq("class_id", student.class_id)
      .eq("teacher_id", caller.userId)
      .is("deleted_at", null)
      .maybeSingle();
    isTeachingClass = Boolean(teaches);
  }

  if (!isSelf && !isAdmin && !isTeachingClass) {
    throw new HttpError(403, "forbidden");
  }

  return student;
}

export const handler = guarded(async (req: Request): Promise<Response> => {
  if (req.method !== "POST") throw new HttpError(405, "method_not_allowed");

  const caller = await requireCaller(req);

  const { studentId, chapterIds, count } = await req.json().catch(() => ({}));
  if (typeof studentId !== "string") throw new HttpError(400, "student_id_required");
  if (!Array.isArray(chapterIds) || chapterIds.length === 0 || chapterIds.some((c) => typeof c !== "string")) {
    throw new HttpError(400, "chapter_ids_required");
  }
  const wanted = typeof count === "number" && count > 0 ? Math.min(count, 40) : DEFAULT_COUNT;

  const db = serviceClient();
  const student = await assertMayRequestFor(db, caller, studentId);
  const specialNeeds = (student.special_needs as string[] | null) ?? [];

  // The Pre-admission learning profile doesn't exist until Phase 9. Treated
  // as absent here so nothing downstream depends on a table that isn't built
  // yet; the prompt is written to make its (future) presence shape
  // presentation only, never difficulty.
  const learningProfile: Record<string, unknown> | null = null;

  const { data: chapters } = await db
    .from("chapters")
    .select("id, title, subjects(name)")
    .in("id", chapterIds)
    .eq("school_id", caller.schoolId);
  if (!chapters?.length) throw new HttpError(404, "chapters_not_found");

  const { data: weaknesses } = await db
    .from("weaknesses")
    .select("micro_skill_id, weight")
    .eq("student_id", studentId)
    .order("weight", { ascending: false });
  const weakSkillIds = new Set(
    (weaknesses ?? []).slice(0, MAX_WEAK_SKILLS).map((w) => w.micro_skill_id as string),
  );

  const gemini = GeminiClient.fromEnvironment();
  const writtenRows: Record<string, unknown>[] = [];

  // One Gemini call per chapter -- exactly as ingestion's pool stage does one
  // call per band -- so a question can only cite a micro-skill of its own
  // chapter and the enum constraint stays small and precise per call.
  const perChapter = Math.max(1, Math.ceil(wanted / chapters.length));

  for (const chapter of chapters) {
    const { data: skills } = await db
      .from("micro_skills")
      .select("id, slug, label, description")
      .eq("chapter_id", chapter.id)
      .order("ordinal");
    if (!skills?.length) continue;

    const slugs = skills.map((s) => s.slug as string);
    const byId = new Map(skills.map((s) => [s.slug as string, s.id as string]));
    const weakSlugs = skills
      .filter((s) => weakSkillIds.has(s.id as string))
      .map((s) => s.slug as string);
    const subjectsField = chapter.subjects as unknown;
    const subjectRow = Array.isArray(subjectsField) ? subjectsField[0] : subjectsField;
    const subjectName = (subjectRow as Record<string, unknown> | null)?.name as
      | string
      | undefined;

    const promptLines = [
      `Chapter: "${chapter.title}" (${subjectName ?? "unknown subject"}, Malaysian`,
      `Form 4, English).`,
      ``,
      `Micro-skills:`,
      ...skills.map((s) => `- ${s.slug}: ${s.label} -- ${s.description}`),
      ``,
      `Write exactly ${perChapter} multiple-choice questions for this chapter,`,
      `each with four options, exactly one correct, and plausible distractors`,
      `that reflect real misconceptions. Cite the micro-skill each question`,
      `tests.`,
    ];

    if (weakSlugs.length > 0) {
      promptLines.push(
        ``,
        `This student is weakest on: ${weakSlugs.join(", ")}. Concentrate most`,
        `questions on these skills, while still producing plausible, well-formed`,
        `items -- do not mention weakness to the student anywhere in the text.`,
      );
    } else {
      promptLines.push(
        ``,
        `This student has no recorded weaknesses yet. Produce ordinary,`,
        `unbiased coverage of the chapter's micro-skills.`,
      );
    }

    promptLines.push(
      ``,
      `The student's Pre-admission learning profile is not yet available; if`,
      `one is supplied in the future it only shapes presentation (tone,`,
      `pacing, examples), never difficulty or which skills are tested.`,
    );

    if (specialNeeds.length > 0) {
      promptLines.push(
        ``,
        `This student has the following special-needs labels: ${specialNeeds.join(", ")}.`,
        `Write shorter sentences, use bulleted structure where it helps`,
        `readability, and avoid idioms and figurative language -- keep`,
        `phrasing literal throughout.`,
      );
    }

    const items = await gemini.generateJson<Array<{
      stem: string;
      options: string[];
      correct_index: number;
      rationale: string;
      micro_skill: string;
    }>>({
      prompt: promptLines.join("\n"),
      schema: questionBatchSchema(slugs),
      temperature: 0.9,
    });

    const rows = items
      .filter((item) =>
        byId.has(item.micro_skill) &&
        Array.isArray(item.options) &&
        item.options.length >= 2 &&
        item.options.length <= 6 &&
        item.correct_index >= 0 &&
        item.correct_index < item.options.length
      )
      .map((item) => ({
        id: crypto.randomUUID(),
        school_id: caller.schoolId,
        chapter_id: chapter.id,
        micro_skill_id: byId.get(item.micro_skill)!,
        difficulty: 2,
        stem: item.stem,
        options: item.options,
        correct_index: item.correct_index,
        rationale: item.rationale,
        provenance: "personalised",
        for_student_id: studentId,
      }));

    if (rows.length > 0) {
      const { error } = await db.from("questions").insert(rows);
      if (error) throw new Error(`question insert failed: ${error.message}`);
      writtenRows.push(...rows);
    }
  }

  return json({
    status: "ok",
    modelVersion: MODEL_VERSION,
    count: writtenRows.length,
    questionIds: writtenRows.map((r) => r.id),
  });
});
