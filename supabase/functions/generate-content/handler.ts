import { assertMayActOnStudent, requireCaller, serviceClient } from "../_shared/auth.ts";
import { GeminiClient } from "../_shared/gemini.ts";
import { guarded, HttpError, json } from "../_shared/http.ts";
import { flashcardDeckSchema, notesSchema, storySchema } from "../_shared/schemas.ts";

const MODEL_VERSION = "gemini-2.5-flash";
const KINDS = new Set(["flashcards", "story", "notes"]);

interface Body {
  kind: "flashcards" | "story" | "notes";
  chapterId: string;
  studentId: string;
  /// prep biases a gentler story; revise is the default.
  mode: "prep" | "revise";
  /// notes only: restrict to these micro-skill ids (the ones the student
  /// just missed). Absent means the whole chapter.
  microSkillIds?: string[];
}

function validateBody(raw: unknown): Body {
  if (typeof raw !== "object" || raw === null) throw new HttpError(400, "invalid_body");
  const b = raw as Record<string, unknown>;
  if (typeof b.kind !== "string" || !KINDS.has(b.kind)) {
    throw new HttpError(400, "kind_required");
  }
  if (typeof b.chapterId !== "string") throw new HttpError(400, "chapter_id_required");
  if (typeof b.studentId !== "string") throw new HttpError(400, "student_id_required");
  const mode = b.mode === "prep" ? "prep" : "revise";
  const microSkillIds = Array.isArray(b.microSkillIds)
    ? b.microSkillIds.filter((v): v is string => typeof v === "string")
    : undefined;
  return {
    kind: b.kind as Body["kind"],
    chapterId: b.chapterId,
    studentId: b.studentId,
    mode,
    microSkillIds,
  };
}

/// Everything below reads the Chapter Knowledge Pack, its micro-skills and
/// their explanations — never the raw material file. This is what holds the
/// offline payload near 100 KB per chapter and is asserted by the seam test.
async function loadPackContext(
  db: ReturnType<typeof serviceClient>,
  schoolId: string,
  chapterId: string,
) {
  const { data: chapter } = await db
    .from("chapters")
    .select("id, title, subjects(name)")
    .eq("id", chapterId)
    .eq("school_id", schoolId)
    .maybeSingle();
  if (!chapter) throw new HttpError(404, "chapter_not_found");

  const { data: pack } = await db
    .from("knowledge_packs")
    .select("concepts, definitions, formulas, worked_examples")
    .eq("chapter_id", chapterId)
    .maybeSingle();
  if (!pack) throw new HttpError(409, "chapter_not_ingested");

  const { data: skills } = await db
    .from("micro_skills")
    .select("id, slug, label, description")
    .eq("chapter_id", chapterId)
    .order("ordinal");
  if (!skills?.length) throw new HttpError(409, "chapter_has_no_micro_skills");

  const { data: explanations } = await db
    .from("micro_skill_explanations")
    .select("micro_skill_id, body");

  const subjectField = chapter.subjects as unknown;
  const subjectRow = Array.isArray(subjectField) ? subjectField[0] : subjectField;
  const subjectName =
    (subjectRow as Record<string, unknown> | null)?.name as string | undefined;

  return {
    title: chapter.title as string,
    subjectName: subjectName ?? "unknown subject",
    pack,
    skills: skills as { id: string; slug: string; label: string; description: string }[],
    explanationsBySkill: new Map(
      (explanations ?? []).map((e) => [e.micro_skill_id as string, e.body as string]),
    ),
  };
}

export const handler = guarded(async (req: Request): Promise<Response> => {
  if (req.method !== "POST") throw new HttpError(405, "method_not_allowed");

  const caller = await requireCaller(req);
  const body = validateBody(await req.json().catch(() => null));

  const db = serviceClient();
  // A student may only request content for themselves; the reference let a
  // student pull another student's material. A teacher or admin may request
  // for a student they are responsible for.
  const student = await assertMayActOnStudent(db, caller, body.studentId);
  const specialNeeds = (student.special_needs as string[] | null) ?? [];

  const ctx = await loadPackContext(db, caller.schoolId, body.chapterId);
  const slugById = new Map(ctx.skills.map((s) => [s.id, s.slug]));
  const idBySlug = new Map(ctx.skills.map((s) => [s.slug, s.id]));

  const targetSlugs = body.microSkillIds && body.microSkillIds.length > 0
    ? body.microSkillIds.map((id) => slugById.get(id)).filter((s): s is string => Boolean(s))
    : ctx.skills.map((s) => s.slug);
  const slugs = targetSlugs.length > 0 ? targetSlugs : ctx.skills.map((s) => s.slug);

  const shared = [
    `Chapter: "${ctx.title}" (${ctx.subjectName}, Malaysian Form 4, English).`,
    ``,
    `Micro-skills you may reference (use the slug):`,
    ...ctx.skills.map((s) => `- ${s.slug}: ${s.label} -- ${s.description}`),
    ``,
    `Knowledge Pack concepts and worked examples (your only source — do not`,
    `introduce material that is not here):`,
    JSON.stringify(ctx.pack).slice(0, 6000),
  ];
  if (specialNeeds.length > 0) {
    shared.push(
      ``,
      `This student has special-needs labels: ${specialNeeds.join(", ")}. Use`,
      `short sentences, bulleted structure where it helps, and literal`,
      `phrasing — no idioms or figurative language.`,
    );
  }

  const gemini = GeminiClient.fromEnvironment();
  let payload: Record<string, unknown>;

  if (body.kind === "flashcards") {
    const prompt = [
      ...shared,
      ``,
      `Produce a flashcard deck of 15 to 30 cards covering these micro-skills:`,
      slugs.join(", "),
      `Each card: a short prompt on the front, the answer on the back, the`,
      `concept name it covers, and the micro-skill slug it tests.`,
    ].join("\n");
    const deck = await gemini.generateJson<{ cards: unknown[] }>({
      prompt,
      schema: flashcardDeckSchema(slugs),
      temperature: 0.7,
    });
    const cards = (deck.cards as Record<string, unknown>[])
      .filter((c) => idBySlug.has(c.micro_skill as string))
      .map((c) => ({
        front: c.front,
        back: c.back,
        concept: c.concept,
        microSkillId: idBySlug.get(c.micro_skill as string),
      }));
    if (cards.length < 15) throw new HttpError(502, "deck_too_small");
    payload = { cards };
  } else if (body.kind === "story") {
    const prompt = [
      ...shared,
      ``,
      body.mode === "prep"
        ? `Write a gentle, encouraging introductory story for a student who has`
          + ` not been taught this chapter yet. Keep the tone light and curious;`
          + ` do not assume prior knowledge.`
        : `Write a revision story for a student who has been taught this`
          + ` chapter and is consolidating it. It may assume the basics and`
          + ` push a little further.`,
      `4 to 10 scenes. Each scene is a caption and a longer description — this`,
      `is text, not an illustration. List the chapter concepts the story`,
      `teaches.`,
    ].join("\n");
    const story = await gemini.generateJson<Record<string, unknown>>({
      prompt,
      schema: storySchema(),
      temperature: 0.8,
    });
    payload = { ...story, mode: body.mode };
  } else {
    const prompt = [
      ...shared,
      ``,
      `Write targeted revision notes covering exactly these micro-skills:`,
      slugs.join(", "),
      ...ctx.skills
        .filter((s) => slugs.includes(s.slug) && ctx.explanationsBySkill.has(s.id))
        .map((s) => `Existing explanation for ${s.slug}: ${ctx.explanationsBySkill.get(s.id)}`),
      ``,
      `One section per micro-skill: a heading and a focused explanation with a`,
      `worked example where it helps.`,
    ].join("\n");
    const notes = await gemini.generateJson<{ sections: Record<string, unknown>[] }>({
      prompt,
      schema: notesSchema(slugs),
      temperature: 0.5,
    });
    payload = {
      sections: notes.sections
        .filter((s) => idBySlug.has(s.micro_skill as string))
        .map((s) => ({
          microSkillId: idBySlug.get(s.micro_skill as string),
          heading: s.heading,
          body: s.body,
        })),
    };
  }

  // Persisted inside the call that produced it, before responding, so a
  // dropped client connection cannot lose the student's content.
  const row = {
    id: crypto.randomUUID(),
    school_id: caller.schoolId,
    chapter_id: body.chapterId,
    student_id: body.studentId,
    kind: body.kind,
    payload,
    model_version: MODEL_VERSION,
  };
  const { error } = await db.from("generated_content").insert(row);
  if (error) throw new Error(`generated_content insert failed: ${error.message}`);

  return json({ id: row.id, kind: body.kind, payload });
});
