import { createClient } from "@supabase/supabase-js";

const db = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  { auth: { persistSession: false } },
);

const SCHOOL = "3a790e4f-3c06-4512-825c-ac8dca0638a5";

const { data: mats } = await db.from("materials")
  .select("id, ingestion_status, chapter_id").eq("school_id", SCHOOL);
console.log(
  "materials:",
  mats!.length,
  "ready:",
  mats!.filter((m) => m.ingestion_status === "ready").length,
);
console.log(
  "  statuses:",
  JSON.stringify(
    mats!.reduce((a: Record<string, number>, m) => {
      a[m.ingestion_status as string] = (a[m.ingestion_status as string] ?? 0) +
        1;
      return a;
    }, {}),
  ),
);

const { data: chapters } = await db.from("chapters")
  .select("id, title, micro_skills_locked_at").eq("school_id", SCHOOL)
  .order("title");

let allOk = true;
for (const ch of chapters!) {
  const { data: skills } = await db.from("micro_skills")
    .select("id, slug").eq("chapter_id", ch.id);
  const { data: qs } = await db.from("questions")
    .select("difficulty, micro_skill_id").eq("chapter_id", ch.id)
    .eq("provenance", "pool");
  const bands = new Set(qs!.map((q) => q.difficulty));
  const skillIds = skills!.map((s) => s.id as string);
  const { data: expl } = await db.from("micro_skill_explanations")
    .select("micro_skill_id").in("micro_skill_id", skillIds);
  const explCounts = new Map<string, number>();
  for (const e of expl!) {
    explCounts.set(
      e.micro_skill_id as string,
      (explCounts.get(e.micro_skill_id as string) ?? 0) + 1,
    );
  }
  const explOk = skillIds.every((id) => explCounts.get(id) === 1);
  const skillOk = skills!.length >= 5 && skills!.length <= 8;
  const lockOk = ch.micro_skills_locked_at !== null;
  const qOk = qs!.length >= 40 && bands.size === 3;
  const ok = skillOk && lockOk && qOk && explOk;
  if (!ok) allOk = false;
  console.log(
    `${ok ? "OK " : "XX "}${(ch.title as string).slice(0, 40).padEnd(42)} ` +
      `skills=${skills!.length} locked=${lockOk} ` +
      `pool=${qs!.length} bands=${[...bands].sort().join(",")} ` +
      `expl_1each=${explOk}`,
  );
}

// cross-chapter citation check: every question's micro-skill must sit in the
// question's own chapter.
const { data: allQ } = await db.from("questions")
  .select("chapter_id, micro_skills(chapter_id)")
  .eq("school_id", SCHOOL);
const cross = (allQ ?? []).filter((q) => {
  const ms = q.micro_skills as unknown as { chapter_id: string } | null;
  return !ms || ms.chapter_id !== q.chapter_id;
}).length;
console.log("cross-chapter citations:", cross);
console.log(allOk && cross === 0 ? "ALL CHECKS PASS" : "FAILURES PRESENT");
