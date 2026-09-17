import { type Caller, requireCaller, requireRole, serviceClient } from "../_shared/auth.ts";
import { GeminiClient } from "../_shared/gemini.ts";
import { guarded, HttpError, json } from "../_shared/http.ts";
import {
  explanationBatchSchema,
  knowledgePackSchema,
  questionBatchSchema,
} from "../_shared/schemas.ts";

const MODEL_VERSION = "gemini-2.5-flash";
const ITEMS_PER_SKILL_PER_BAND = 5;

// A transient upstream-capacity error must not consume a material's retry budget
// or ever mark it `failed`: "ingestion is resumable, not transactional". These
// are the exact strings GeminiClient produces when every key is rate limited or
// its rotation is exhausted (429/5xx and network-error exhaustion).
export function isTransientQuotaError(msg: string): boolean {
  return /rate limited|exhausted/i.test(msg);
}

function slugify(value: string): string {
  return value.toLowerCase().replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "").slice(0, 48);
}

// Signature is verified by the gateway (verify_jwt) before the handler runs, so
// this decode-only check just reads the already-trusted role claim.
function isServiceRoleBearer(authorization: string): boolean {
  try {
    if (!authorization.startsWith("Bearer ")) return false;
    const token = authorization.slice("Bearer ".length);
    const payload = token.split(".")[1];
    const json = atob(payload.replace(/-/g, "+").replace(/_/g, "/"));
    return JSON.parse(json).role === "service_role";
  } catch {
    return false;
  }
}

function toBase64(bytes: Uint8Array): string {
  let binary = "";
  for (const byte of bytes) binary += String.fromCharCode(byte);
  return btoa(binary);
}

export const handler = guarded(async (req: Request): Promise<Response> => {
  if (req.method !== "POST") throw new HttpError(405, "method_not_allowed");

  // The cron sweep authenticates as the service role, which has no profile.
  // Try the normal caller path first; only fall back to the sweep path when the
  // bearer is a service_role JWT. Its signature is already verified by the
  // function gateway (verify_jwt) before this handler runs, so decoding the
  // payload without re-verifying is sufficient here.
  const authorization = req.headers.get("Authorization") ?? "";
  let caller: Caller | null = null;
  try {
    caller = await requireCaller(req);
    requireRole(caller, "teacher", "admin");
  } catch (err) {
    if (!isServiceRoleBearer(authorization)) throw err;
    // caller stays null -> sweep path
  }

  const { materialId } = await req.json().catch(() => ({}));
  if (typeof materialId !== "string") throw new HttpError(400, "material_id_required");

  const db = serviceClient();
  let query = db
    .from("materials")
    .select("*, chapters(id, title, micro_skills_locked_at, subjects(name))")
    .eq("id", materialId);
  if (caller) query = query.eq("school_id", caller.schoolId);
  const { data: material } = await query.maybeSingle();

  if (!material) throw new HttpError(404, "material_not_found");

  const schoolId = caller ? caller.schoolId : (material.school_id as string);

  const gemini = GeminiClient.fromEnvironment();
  const chapter = material.chapters as Record<string, unknown>;
  const chapterId = chapter.id as string;
  const chapterTitle = chapter.title as string;
  const subjectName = (chapter.subjects as Record<string, unknown>).name as string;

  try {
    switch (material.ingestion_status) {
      case "pending":
        return json(await stagePack());
      case "pack_ready":
        return json(await stagePool());
      case "pool_ready":
        return json(await stageExplanations());
      default:
        return json({ status: material.ingestion_status, stage: "none" });
    }
  } catch (error) {
    const msg = (error as Error).message;
    // Transient Gemini quota/capacity exhaustion is not the material's fault:
    // record the error but leave attempts and status untouched so the cron
    // sweep keeps retrying once quota recovers.
    const transientQuota = isTransientQuotaError(msg);
    await db.from("materials").update({
      ingestion_error: msg.slice(0, 500),
      ...(transientQuota ? {} : {
        attempts: (material.attempts ?? 0) + 1,
        ingestion_status: (material.attempts ?? 0) >= 2 ? "failed" : material.ingestion_status,
      }),
    }).eq("id", materialId);
    throw error;
  }

  // ── stage 1 ────────────────────────────────────────────────────────────
  // The only stage that reads the file. Everything after this reads the pack,
  // which is what keeps later generation fast, cheap and consistent.
  async function stagePack() {
    const { data: file, error } = await db.storage
      .from("materials").download(material.storage_path);
    if (error || !file) throw new Error(`could not download material: ${error?.message}`);

    const bytes = new Uint8Array(await file.arrayBuffer());

    const pack = await gemini.generateJson<{
      concepts: unknown[];
      definitions: unknown[];
      formulas: unknown[];
      worked_examples: unknown[];
      difficulty_markers: unknown[];
      source_refs: unknown[];
      micro_skills: Array<{ slug: string; label: string; description: string }>;
    }>({
      prompt: [
        `You are analysing teaching material for "${chapterTitle}" in ${subjectName},`,
        `at Malaysian secondary Form 4 level, taught in English.`,
        ``,
        `Extract a Chapter Knowledge Pack: the concepts, definitions, formulas and`,
        `worked examples actually present in the document.`,
        ``,
        `Then identify between FIVE and EIGHT micro-skills: the smallest units of`,
        `understanding a question could test. Each needs a short kebab-case slug`,
        `unique within this chapter, a human label, and one sentence of description.`,
        `These slugs become permanent identifiers for every analytic in the system,`,
        `so prefer durable, specific names over clever ones.`,
      ].join("\n"),
      schema: knowledgePackSchema(),
      files: [{ mimeType: material.mime_type, data: toBase64(bytes) }],
      temperature: 0.2,
    });

    const skills = pack.micro_skills.slice(0, 8);
    if (skills.length < 5) {
      throw new Error(`expected 5-8 micro-skills, model returned ${skills.length}`);
    }

    // Resumable, not transactional: a retry re-enters this stage, and
    // knowledge_packs has unique(material_id). Skip the write when a pack for
    // this material already exists so the retry can proceed to the later steps.
    const { data: existingPack } = await db
      .from("knowledge_packs").select("id").eq("material_id", materialId).maybeSingle();
    if (!existingPack) {
      const { error: packError } = await db.from("knowledge_packs").insert({
        id: crypto.randomUUID(),
        school_id: schoolId,
        chapter_id: chapterId,
        material_id: materialId,
        concepts: pack.concepts,
        definitions: pack.definitions,
        formulas: pack.formulas,
        worked_examples: pack.worked_examples,
        difficulty_markers: pack.difficulty_markers,
        source_refs: pack.source_refs,
        model_version: MODEL_VERSION,
      });
      if (packError) throw new Error(`knowledge pack insert failed: ${packError.message}`);
    }

    // Only the first material for a chapter establishes the vocabulary. A
    // later one enriches the pack and adds pool items under the same slugs.
    // The conditional update below is the mutual exclusion: it stamps
    // micro_skills_locked_at only if it is still null, and returns the row
    // just for the invocation that won that transition. Concurrent or prior
    // stagePack calls (including a re-ingestion of an already-locked chapter)
    // do not win, skip the insert, and proceed to the pack write + advance.
    const { data: locked } = await db.from("chapters")
      .update({ micro_skills_locked_at: new Date().toISOString() })
      .eq("id", chapterId).is("micro_skills_locked_at", null)
      .select("id");

    const { data: priorSkills } = await db
      .from("micro_skills").select("id").eq("chapter_id", chapterId).limit(1);

    if (locked && locked.length > 0 && !priorSkills?.length) {
      const seen = new Set<string>();
      const rows = skills.map((skill, index) => {
        let slug = slugify(skill.slug || skill.label);
        while (seen.has(slug)) slug = `${slug}-${index}`;
        seen.add(slug);
        return {
          id: crypto.randomUUID(),
          school_id: schoolId,
          chapter_id: chapterId,
          slug,
          label: skill.label,
          description: skill.description,
          ordinal: index + 1,
        };
      });

      const { error: insertError } = await db.from("micro_skills").insert(rows);
      if (insertError) throw new Error(`micro-skill insert failed: ${insertError.message}`);
    }

    await db.from("materials")
      .update({
        ingestion_status: "pack_ready",
        ingestion_error: null,
        attempts: 0,
        pool_bands_done: 0,
      })
      .eq("id", materialId);

    return { status: "pack_ready", stage: "pack", counts: { micro_skills: skills.length } };
  }

  // ── stage 2 ────────────────────────────────────────────────────────────
  // One difficulty band per invocation: generating all three bands (~120
  // questions) in a single Edge Function call hits WORKER_RESOURCE_LIMIT
  // deterministically. Progress is tracked on materials.pool_bands_done, and
  // the status stays "pack_ready" between bands so the cron sweep and any
  // driver re-invoke for the next one.
  async function stagePool() {
    const poolBandsDone = (material.pool_bands_done as number | null) ?? 0;

    if (poolBandsDone >= 3) {
      // A death right before the status flip: bands are all written, just
      // advance the status.
      await db.from("materials")
        .update({ ingestion_status: "pool_ready", ingestion_error: null, attempts: 0 })
        .eq("id", materialId);
      return { status: "pool_ready", stage: "pool", counts: {} };
    }

    const band = poolBandsDone + 1;

    const { data: skills } = await db
      .from("micro_skills").select("id, slug, label, description")
      .eq("chapter_id", chapterId).order("ordinal");
    if (!skills?.length) throw new Error("no micro-skills for chapter");

    const { data: pack } = await db
      .from("knowledge_packs").select("*").eq("material_id", materialId).single();

    const slugs = skills.map((s) => s.slug as string);
    const byId = new Map(skills.map((s) => [s.slug as string, s.id as string]));
    const bandNames = ["recall and direct application", "multi-step application", "reasoning and transfer"];

    const wanted = slugs.length * ITEMS_PER_SKILL_PER_BAND;

    const items = await gemini.generateJson<Array<{
      stem: string;
      options: string[];
      correct_index: number;
      rationale: string;
      micro_skill: string;
    }>>({
      prompt: [
        `Chapter: "${chapterTitle}" (${subjectName}, Malaysian Form 4, English).`,
        ``,
        `Knowledge Pack:`,
        JSON.stringify({
          concepts: pack!.concepts,
          definitions: pack!.definitions,
          formulas: pack!.formulas,
          worked_examples: pack!.worked_examples,
        }),
        ``,
        `Micro-skills:`,
        ...skills.map((s) => `- ${s.slug}: ${s.label} -- ${s.description}`),
        ``,
        `Write exactly ${wanted} multiple-choice questions at difficulty band ${band}`,
        `of 3 (${bandNames[band - 1]}).`,
        `Produce ${ITEMS_PER_SKILL_PER_BAND} questions for EACH micro-skill listed.`,
        `Every question needs four options, exactly one correct, and plausible`,
        `distractors that reflect real misconceptions rather than obvious errors.`,
        `Cite the micro-skill the question tests.`,
      ].join("\n"),
      schema: questionBatchSchema(slugs),
      temperature: 0.9,
    });

    // Resumable, not transactional: a retry re-runs just this band. Drop only
    // this band's rows for this material so completed bands are untouched.
    await db.from("questions").delete()
      .eq("material_id", materialId).eq("difficulty", band);

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
        school_id: schoolId,
        chapter_id: chapterId,
        material_id: materialId,
        micro_skill_id: byId.get(item.micro_skill)!,
        difficulty: band,
        stem: item.stem,
        options: item.options,
        correct_index: item.correct_index,
        rationale: item.rationale,
        provenance: "pool",
      }));

    let written = 0;
    if (rows.length > 0) {
      const { error } = await db.from("questions").insert(rows);
      if (error) throw new Error(`question insert failed: ${error.message}`);
      written += rows.length;
    }

    const done = band;
    const status = done >= 3 ? "pool_ready" : "pack_ready";
    await db.from("materials")
      .update({
        pool_bands_done: done,
        ingestion_status: status,
        ingestion_error: null,
        attempts: 0,
      })
      .eq("id", materialId);

    return { status, stage: "pool", counts: { band: done, questions: written } };
  }

  // ── stage 3 ────────────────────────────────────────────────────────────
  // These power offline targeted notes: when a student misses a micro-skill
  // with no connectivity, this is the material they read.
  async function stageExplanations() {
    const { data: skills } = await db
      .from("micro_skills").select("id, slug, label, description")
      .eq("chapter_id", chapterId).order("ordinal");
    if (!skills?.length) throw new Error("no micro-skills for chapter");

    const { data: existing } = await db
      .from("micro_skill_explanations").select("micro_skill_id")
      .in("micro_skill_id", skills!.map((s) => s.id as string));
    const have = new Set((existing ?? []).map((e) => e.micro_skill_id as string));

    const missing = skills!.filter((s) => !have.has(s.id as string));

    if (missing.length > 0) {
      const { data: pack } = await db
        .from("knowledge_packs").select("*").eq("material_id", materialId).single();

      const bodies = await gemini.generateJson<Array<{ micro_skill: string; body: string }>>({
        prompt: [
          `Chapter: "${chapterTitle}" (${subjectName}, Malaysian Form 4, English).`,
          ``,
          `Knowledge Pack:`,
          JSON.stringify({
            concepts: pack!.concepts,
            definitions: pack!.definitions,
            formulas: pack!.formulas,
            worked_examples: pack!.worked_examples,
          }),
          ``,
          `Write one short revision note per micro-skill below. Each should be`,
          `120-200 words of Markdown: what the skill is, the one mistake students`,
          `most often make, and a single worked example. Write for a student who`,
          `has just got a question on it wrong.`,
          ``,
          ...missing.map((s) => `- ${s.slug}: ${s.label} -- ${s.description}`),
        ].join("\n"),
        schema: explanationBatchSchema(missing.map((s) => s.slug as string)),
        temperature: 0.5,
      });

      const bySlug = new Map(skills!.map((s) => [s.slug as string, s.id as string]));
      const rows = bodies
        .filter((entry) => bySlug.has(entry.micro_skill))
        .map((entry) => ({
          id: crypto.randomUUID(),
          school_id: schoolId,
          micro_skill_id: bySlug.get(entry.micro_skill)!,
          body: entry.body,
        }));

      if (rows.length > 0) {
        await db.from("micro_skill_explanations")
          .upsert(rows, { onConflict: "micro_skill_id", ignoreDuplicates: true });
      }
    }

    await db.from("materials").update({
      ingestion_status: "ready",
      ingestion_error: null,
      attempts: 0,
      ingested_at: new Date().toISOString(),
    }).eq("id", materialId);

    return { status: "ready", stage: "explanations", counts: { explanations: missing.length } };
  }
});
