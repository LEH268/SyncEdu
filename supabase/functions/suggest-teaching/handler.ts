import { requireCaller, requireRole, serviceClient } from "../_shared/auth.ts";
import { GeminiClient } from "../_shared/gemini.ts";
import { guarded, HttpError, json } from "../_shared/http.ts";
import { teachingReviewSchema } from "../_shared/schemas.ts";

const MODEL_VERSION = "gemini-2.5-flash";
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/// One micro-skill the console's Dart analytics flagged, with the comparison
/// against the teacher's other classes that says what kind of problem it is.
/// Every number here was computed by `reviewTeaching`; none is recomputed.
interface Signal {
  microSkillId: string;
  sentence: string;
  scope: "materialWide" | "classSpecific" | "insufficientComparison";
  misconceptions: { questionStem: string; optionText: string; studentCount: number }[];
}

interface Body {
  /// Client-supplied, so the row this call persists and the row the outbox
  /// later pushes are the same row (tier 1, idempotent on the id).
  insightId: string;
  classId: string;
  chapterId: string;
  className: string;
  /// The Dart-rendered headline, handed over so the model can be told what
  /// the deterministic reading already is and asked to elaborate rather than
  /// re-derive it.
  ruleHeadline: string;
  signals: Signal[];
}

const SCOPES = new Set(["materialWide", "classSpecific", "insufficientComparison"]);

function validateBody(raw: unknown): Body {
  if (typeof raw !== "object" || raw === null) throw new HttpError(400, "invalid_body");
  const b = raw as Record<string, unknown>;

  if (typeof b.insightId !== "string" || !UUID.test(b.insightId)) {
    throw new HttpError(400, "insight_id_required");
  }
  if (typeof b.classId !== "string" || !UUID.test(b.classId)) {
    throw new HttpError(400, "class_id_required");
  }
  if (typeof b.chapterId !== "string" || !UUID.test(b.chapterId)) {
    throw new HttpError(400, "chapter_id_required");
  }
  if (typeof b.className !== "string" || b.className.trim().length === 0) {
    throw new HttpError(400, "class_name_required");
  }
  if (typeof b.ruleHeadline !== "string" || b.ruleHeadline.trim().length === 0) {
    throw new HttpError(400, "rule_headline_required");
  }

  // The signals are the whole point of the call: prose about no finding is
  // not a review, it is an invitation to invent one.
  const isSignal = (item: unknown): item is Signal => {
    if (typeof item !== "object" || item === null) return false;
    const s = item as Record<string, unknown>;
    if (typeof s.microSkillId !== "string" || !UUID.test(s.microSkillId)) return false;
    if (typeof s.sentence !== "string" || s.sentence.length === 0) return false;
    if (typeof s.scope !== "string" || !SCOPES.has(s.scope)) return false;
    if (!Array.isArray(s.misconceptions)) return false;
    return s.misconceptions.every((m: unknown) =>
      typeof m === "object" && m !== null &&
      typeof (m as Record<string, unknown>).questionStem === "string" &&
      typeof (m as Record<string, unknown>).optionText === "string" &&
      typeof (m as Record<string, unknown>).studentCount === "number"
    );
  };
  if (!Array.isArray(b.signals) || b.signals.length === 0 || !b.signals.every(isSignal)) {
    throw new HttpError(400, "signals_required");
  }

  return {
    insightId: b.insightId,
    classId: b.classId,
    chapterId: b.chapterId,
    className: b.className,
    ruleHeadline: b.ruleHeadline,
    signals: b.signals as Signal[],
  };
}

/// The caller must actually take this class. RLS would refuse the insert
/// anyway, but this function reads the chapter's Knowledge Pack with the
/// service role first -- so the check has to happen before that read, not
/// after it.
async function assertTeachesClass(
  db: ReturnType<typeof serviceClient>,
  teacherId: string,
  schoolId: string,
  classId: string,
): Promise<void> {
  const { data } = await db
    .from("class_subjects")
    .select("id")
    .eq("class_id", classId)
    .eq("teacher_id", teacherId)
    .eq("school_id", schoolId)
    .is("deleted_at", null)
    .limit(1)
    .maybeSingle();
  if (!data) throw new HttpError(403, "forbidden");
}

/// Reads the chapter's Knowledge Pack, micro-skills and explanations -- the
/// same derived content `generate-content` grounds on, never the raw material
/// file. The pack was extracted from the teacher's own upload, so the deck
/// stays anchored to what they actually presented without paying for a second
/// file read on every generation.
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
    .select("micro_skill_id, body")
    .in("micro_skill_id", skills.map((s) => s.id as string));

  const subjectField = chapter.subjects as unknown;
  const subjectRow = Array.isArray(subjectField) ? subjectField[0] : subjectField;

  return {
    title: chapter.title as string,
    subjectName:
      ((subjectRow as Record<string, unknown> | null)?.name as string | undefined) ??
        "unknown subject",
    pack,
    skills: skills as { id: string; slug: string; label: string; description: string }[],
    explanationsBySkill: new Map(
      (explanations ?? []).map((e) => [e.micro_skill_id as string, e.body as string]),
    ),
  };
}

function buildPrompt(
  input: Body,
  ctx: Awaited<ReturnType<typeof loadPackContext>>,
  flagged: { slug: string; label: string; signal: Signal; explanation?: string }[],
): string {
  return [
    `A teacher of "${input.className}" has just been shown a diagnostic over`,
    `their class's results on the chapter "${ctx.title}" (${ctx.subjectName}).`,
    `You are writing the improvement advice and a re-teach slide deck.`,
    ``,
    `THE FINDINGS. These were computed from quiz results before you were`,
    `called. Treat every one as fact, cite them as written, and invent no`,
    `figure, student, class or concept that does not appear below.`,
    ``,
    `Overall: ${input.ruleHeadline}`,
    ``,
    ...flagged.flatMap((f) => [
      `- ${f.slug} ("${f.label}"): ${f.signal.sentence}`,
      ...(f.signal.misconceptions.length > 0
        ? [
          `  Wrong answers students actually chose:`,
          ...f.signal.misconceptions.map((m) =>
            `    "${m.optionText}" on "${m.questionStem}" (${m.studentCount} students)`
          ),
        ]
        : []),
      ...(f.explanation ? [`  Current explanation given to students: ${f.explanation}`] : []),
    ]),
    ``,
    `THE MATERIAL. This Knowledge Pack was extracted from the teacher's own`,
    `uploaded slides for this chapter. It is your only source of subject`,
    `content -- do not introduce material that is not in it:`,
    JSON.stringify(ctx.pack).slice(0, 6000),
    ``,
    `WRITE THREE THINGS.`,
    ``,
    `1. summary: 4 to 6 sentences addressed to the teacher. Say which skills`,
    `   did not land and, where the finding says so, that the same skill also`,
    `   failed in their other classes -- which points at how the material`,
    `   presents it rather than at the class. Where a misconception is listed,`,
    `   name it: the wrong answer students chose is evidence about which step`,
    `   of the explanation is being misread. Be concrete and collegial. Do not`,
    `   grade or rate the teacher, and do not speculate about anything outside`,
    `   these findings.`,
    ``,
    `2. actions: 2 to 6 specific changes to how a flagged skill is presented.`,
    `   Each names the micro-skill slug it addresses. A change is something a`,
    `   teacher can do to a slide or to a explanation next lesson -- "introduce`,
    `   the discriminant with a sign table before the formula", not "revise`,
    `   more".`,
    ``,
    `3. slides + deck_title: a re-teach deck of 6 to 16 slides covering ONLY`,
    `   the flagged micro-skills, taking a different angle from the current`,
    `   explanation above rather than restating it. Include at least one`,
    `   worked example slide per flagged skill, and where a misconception is`,
    `   listed, one slide that confronts that specific wrong answer and shows`,
    `   why it is wrong. Each slide: a title, 1 to 6 short bullets (a bullet`,
    `   is a phrase on a slide, not a paragraph), and speaker notes saying`,
    `   what to say while it is up.`,
  ].join("\n");
}

export const handler = guarded(async (req: Request): Promise<Response> => {
  if (req.method !== "POST") throw new HttpError(405, "method_not_allowed");

  const caller = await requireCaller(req);
  // Teacher-only, deliberately. This review is the teacher's own diagnostic;
  // an admin-readable version of it would turn it into an appraisal record,
  // which the design spec rules out (section 11).
  requireRole(caller, "teacher");

  const body = validateBody(await req.json().catch(() => null));

  const db = serviceClient();
  await assertTeachesClass(db, caller.userId, caller.schoolId, body.classId);

  const ctx = await loadPackContext(db, caller.schoolId, body.chapterId);
  const skillById = new Map(ctx.skills.map((s) => [s.id, s]));
  const idBySlug = new Map(ctx.skills.map((s) => [s.slug, s.id]));

  // A signal naming a micro-skill outside this chapter is dropped rather than
  // passed through: the enumerated schema below is built from what survives,
  // so the deck can only ever cite this chapter's own vocabulary.
  const flagged = body.signals
    .map((signal) => {
      const skill = skillById.get(signal.microSkillId);
      if (!skill) return null;
      return {
        slug: skill.slug,
        label: skill.label,
        signal,
        explanation: ctx.explanationsBySkill.get(skill.id),
      };
    })
    .filter((f): f is NonNullable<typeof f> => f !== null);

  if (flagged.length === 0) throw new HttpError(400, "no_signal_matches_chapter");

  const slugs = flagged.map((f) => f.slug);

  const gemini = GeminiClient.fromEnvironment();
  const generated = await gemini.generateJson<{
    summary: string;
    actions: { micro_skill: string; title: string; detail: string }[];
    deck_title: string;
    slides: { micro_skill: string; title: string; bullets: string[]; notes: string }[];
  }>({
    prompt: buildPrompt(body, ctx, flagged),
    schema: teachingReviewSchema(slugs),
    temperature: 0.5,
  });

  const actions = generated.actions
    .filter((a) => idBySlug.has(a.micro_skill))
    .map((a) => ({
      microSkillId: idBySlug.get(a.micro_skill),
      title: a.title,
      detail: a.detail,
    }));
  const slides = generated.slides
    .filter((s) => idBySlug.has(s.micro_skill))
    .map((s) => ({
      microSkillId: idBySlug.get(s.micro_skill),
      title: s.title,
      bullets: s.bullets,
      notes: s.notes,
    }));

  if (slides.length < 4) throw new HttpError(502, "deck_too_small");

  const deck = { title: generated.deck_title, slides };

  // Persisted inside the call that produced it, before responding, so a
  // dropped connection cannot lose the teacher's deck. The console writes the
  // same id into its own mirror and queues it to the outbox; the eventual
  // push is an ignore-duplicates upsert against this row.
  const { error } = await db.from("teaching_insights").insert({
    id: body.insightId,
    school_id: caller.schoolId,
    teacher_id: caller.userId,
    class_id: body.classId,
    chapter_id: body.chapterId,
    signals: body.signals,
    summary: generated.summary,
    actions,
    deck,
    source: "ai",
    model_version: MODEL_VERSION,
  });
  if (error) throw new Error(`teaching_insights insert failed: ${error.message}`);

  return json({
    id: body.insightId,
    summary: generated.summary,
    actions,
    deck,
    source: "ai",
  });
});
