// Measure what a student device actually mirrors, per chapter.
//
// The spec's claim (§4.3) is roughly 100 KB per chapter and about 1 MB for
// ten. If it is materially larger, something is being mirrored that should
// not be -- most likely raw material text leaking into a pack.
//
//   deno run --allow-all --env-file=.env scripts/measure_offline_payload.ts

import { createClient } from "@supabase/supabase-js";

const db = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  { auth: { persistSession: false } },
);

let schoolId = Deno.env.get("SEED_SCHOOL_ID");
if (!schoolId) {
  const { data: schools } = await db.from("schools")
    .select("id, created_at").order("created_at", { ascending: false });
  for (const s of schools ?? []) {
    const { count } = await db.from("materials")
      .select("id", { count: "exact", head: true })
      .eq("school_id", s.id).eq("ingestion_status", "ready");
    if ((count ?? 0) >= 8) {
      schoolId = s.id;
      break;
    }
  }
}
if (!schoolId) throw new Error("no ingested school found");

const bytes = (v: unknown) =>
  new TextEncoder().encode(JSON.stringify(v ?? null)).length;
const kb = (n: number) => (n / 1024).toFixed(1).padStart(7) + " KB";

const { data: chapters } = await db.from("chapters")
  .select("id, title").eq("school_id", schoolId).order("title");

let totalPack = 0, totalPool = 0, totalExpl = 0, totalGen = 0;
console.log(
  "chapter".padEnd(46) + "pack".padStart(10) + "pool".padStart(11) +
    "expl".padStart(11) + "content".padStart(11) + "total".padStart(11),
);

for (const ch of chapters ?? []) {
  const { data: packs } = await db.from("knowledge_packs")
    .select(
      "concepts, definitions, formulas, worked_examples, difficulty_markers, source_refs",
    )
    .eq("chapter_id", ch.id);
  const { data: qs } = await db.from("questions")
    .select(
      "stem, options, correct_index, rationale, difficulty, micro_skill_id",
    )
    .eq("chapter_id", ch.id).eq("provenance", "pool");
  const { data: skills } = await db.from("micro_skills")
    .select("id").eq("chapter_id", ch.id);
  const skillIds = (skills ?? []).map((s) => s.id);
  const { data: expl } = skillIds.length
    ? await db.from("micro_skill_explanations").select("body").in(
      "micro_skill_id",
      skillIds,
    )
    : { data: [] };
  const { data: gen } = await db.from("generated_content")
    .select("payload, kind").eq("chapter_id", ch.id).is("student_id", null);

  const p = bytes(packs), q = bytes(qs), e = bytes(expl), g = bytes(gen);
  totalPack += p;
  totalPool += q;
  totalExpl += e;
  totalGen += g;
  console.log(
    (ch.title as string).slice(0, 44).padEnd(46) +
      kb(p) + kb(q) + kb(e) + kb(g) + kb(p + q + e + g),
  );
}

const grand = totalPack + totalPool + totalExpl + totalGen;
const n = (chapters ?? []).length;
console.log("-".repeat(100));
console.log(
  `${n} chapters`.padEnd(46) + kb(totalPack) + kb(totalPool) + kb(totalExpl) +
    kb(totalGen) + kb(grand),
);
console.log(`\nper chapter average: ${kb(grand / Math.max(1, n))}`);
console.log(`spec target: ~100 KB/chapter, ~1 MB for ten`);
const perCh = grand / Math.max(1, n);
console.log(
  perCh <= 160 * 1024
    ? "WITHIN BUDGET"
    : "OVER BUDGET — check for raw material text in knowledge_packs",
);
