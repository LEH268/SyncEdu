// Assert the seeded history actually produced the shape it was built for.
//
// This mirrors the thresholds and "per student, then count" discipline in
// packages/syncedu_core/lib/src/analytics. If an assertion fails, ADJUST THE
// SEED and re-run -- never adjust the analytics to match the seed.
//
//   deno run --allow-all --env-file=.env scripts/verify_seed_shape.ts

import { createClient } from "@supabase/supabase-js";

const db = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  { auth: { persistSession: false } },
);

// thresholds — keep in step with AnalyticsThresholds.standard()
const MIN_ITEMS_STUDENT = 3;
const STRUGGLING_BAR = 0.5;
const REC_PROPORTION = 0.4;
const REC_MIN_ASSESSED = 5;
const INACTIVITY_DAYS = 7;
const DECLINE_DROP = 15;
const DECLINE_WINDOW = 3;

const wantSchool = Deno.env.get("SEED_SCHOOL_ID");
let schoolId = wantSchool;
if (!schoolId) {
  const { data: schools } = await db.from("schools")
    .select("id, created_at").order("created_at", { ascending: false });
  for (const s of schools ?? []) {
    const { count } = await db.from("attempts")
      .select("id", { count: "exact", head: true }).eq("school_id", s.id);
    if ((count ?? 0) > 50) {
      schoolId = s.id;
      break;
    }
  }
}
if (!schoolId) throw new Error("no seeded school found");
console.log(`verifying school ${schoolId}\n`);

// base relation: attempt_items JOIN attempts, revise only
const { data: items } = await db.from("attempt_items")
  .select(
    "is_correct, micro_skill_id, " +
      "attempts!inner(id, student_id, mode, submitted_at, score, question_count, parent_attempt_id, attempt_number), " +
      "micro_skills!inner(slug, chapter_id, chapters!inner(title))",
  )
  .eq("school_id", schoolId);

type Row = {
  is_correct: boolean;
  micro_skill_id: string;
  attempts: {
    id: string;
    student_id: string;
    mode: string;
    submitted_at: string;
    score: number;
    question_count: number;
    parent_attempt_id: string | null;
    attempt_number: number;
  };
  micro_skills: {
    slug: string;
    chapter_id: string;
    chapters: { title: string };
  };
};
const rows = (items ?? []) as unknown as Row[];
const revise = rows.filter((r) => r.attempts.mode === "revise");

// students -> class
const { data: studs } = await db.from("students")
  .select("id, class_id, classes(name)").eq("school_id", schoolId);
const classOf = new Map<string, { id: string; name: string }>();
for (const s of studs ?? []) {
  if (s.class_id) {
    classOf.set(s.id, {
      id: s.class_id,
      // deno-lint-ignore no-explicit-any
      name: (s.classes as any)?.name ?? "?",
    });
  }
}

let pass = true;
const check = (ok: boolean, msg: string) => {
  console.log(`${ok ? "OK " : "XX "}${msg}`);
  if (!ok) pass = false;
};

// ---- per (student, skill) accuracy ----
type Acc = { correct: number; total: number };
function perStudentSkill(subset: Row[]) {
  const m = new Map<string, Map<string, Acc>>();
  for (const r of subset) {
    const sid = r.attempts.student_id;
    const bySkill = m.get(sid) ?? m.set(sid, new Map()).get(sid)!;
    const a = bySkill.get(r.micro_skill_id) ?? { correct: 0, total: 0 };
    a.total++;
    if (r.is_correct) a.correct++;
    bySkill.set(r.micro_skill_id, a);
  }
  return m;
}

// ---- 1. exactly one resource recommendation ----
const byClassSkill = new Map<string, Map<string, Row[]>>();
for (const r of revise) {
  const c = classOf.get(r.attempts.student_id);
  if (!c) continue;
  const bySkill = byClassSkill.get(c.id) ??
    byClassSkill.set(c.id, new Map()).get(c.id)!;
  (bySkill.get(r.micro_skill_id) ??
    bySkill.set(r.micro_skill_id, []).get(r.micro_skill_id)!)
    .push(r);
}
const recs: string[] = [];
for (const [classId, bySkill] of byClassSkill) {
  for (const [skillId, skillRows] of bySkill) {
    const psk = perStudentSkill(skillRows);
    let assessed = 0, struggling = 0;
    for (const bySkill2 of psk.values()) {
      const a = bySkill2.get(skillId);
      if (!a || a.total < MIN_ITEMS_STUDENT) continue;
      assessed++;
      if (a.correct / a.total < STRUGGLING_BAR) struggling++;
    }
    if (
      assessed >= REC_MIN_ASSESSED && struggling / assessed >= REC_PROPORTION
    ) {
      const slug = skillRows[0].micro_skills.slug;
      const cname = [...classOf.values()].find((c) => c.id === classId)?.name;
      recs.push(`${cname} / ${slug} (${struggling}/${assessed})`);
    }
  }
}
check(
  recs.length === 1,
  `exactly one resource recommendation fires: [${recs.join("; ")}]`,
);

// ---- 2. exactly three at-risk students, three distinct reasons ----
const attemptsByStudent = new Map<string, Row["attempts"][]>();
const seenAttempt = new Set<string>();
for (const r of revise) {
  if (seenAttempt.has(r.attempts.id)) continue;
  seenAttempt.add(r.attempts.id);
  (attemptsByStudent.get(r.attempts.student_id) ??
    attemptsByStudent.set(r.attempts.student_id, []).get(
      r.attempts.student_id,
    )!)
    .push(r.attempts);
}
const itemsByStudent = new Map<string, Row[]>();
for (const r of revise) {
  (itemsByStudent.get(r.attempts.student_id) ??
    itemsByStudent.set(r.attempts.student_id, []).get(r.attempts.student_id)!)
    .push(r);
}
const now = Date.now();
const atRisk: { sid: string; rules: string[] }[] = [];
for (const [sid, sItems] of itemsByStudent) {
  const rules: string[] = [];
  // low mastery
  if (sItems.length >= MIN_ITEMS_STUDENT) {
    const acc = sItems.filter((r) => r.is_correct).length / sItems.length;
    if (acc < STRUGGLING_BAR) rules.push("low_mastery");
  }
  // multiple failed skills
  const bySkill = new Map<string, Acc>();
  for (const r of sItems) {
    const a = bySkill.get(r.micro_skill_id) ?? { correct: 0, total: 0 };
    a.total++;
    if (r.is_correct) a.correct++;
    bySkill.set(r.micro_skill_id, a);
  }
  let failed = 0;
  for (const a of bySkill.values()) {
    if (a.total >= MIN_ITEMS_STUDENT && a.correct / a.total < STRUGGLING_BAR) {
      failed++;
    }
  }
  if (failed >= 3) rules.push("multiple_failed_skills");
  // inactive
  const ats = (attemptsByStudent.get(sid) ?? []).slice()
    .sort((a, b) => +new Date(a.submitted_at) - +new Date(b.submitted_at));
  if (ats.length) {
    const gap = (now - +new Date(ats[ats.length - 1].submitted_at)) / 86400_000;
    if (gap >= INACTIVITY_DAYS) rules.push("inactive");
  }
  // declining
  if (ats.length >= DECLINE_WINDOW) {
    const recent = ats.slice(-DECLINE_WINDOW).map((a) =>
      a.question_count === 0 ? 0 : (a.score / a.question_count) * 100
    );
    let dec = true;
    for (let i = 1; i < recent.length; i++) {
      if (recent[i - 1] - recent[i] < DECLINE_DROP) dec = false;
    }
    if (dec) rules.push("declining");
  }
  if (rules.length) atRisk.push({ sid, rules });
}
check(
  atRisk.length === 3,
  `exactly three students at risk (got ${atRisk.length})`,
);
const distinctRules = new Set(atRisk.flatMap((r) => r.rules));
check(
  distinctRules.size === 3 &&
    ["low_mastery", "inactive", "declining"].every((r) => distinctRules.has(r)),
  `three distinct rules: {${[...distinctRules].join(", ")}}`,
);
check(
  atRisk.every((r) => r.rules.length === 1),
  "each at-risk student trips exactly one rule (no rule wearing three hats)",
);
check(
  (studs ?? []).length - atRisk.length > atRisk.length,
  `healthy students outnumber at-risk (${
    (studs ?? []).length - atRisk.length
  } vs ${atRisk.length})`,
);

// ---- 3. one improving student across a single chain ----
let improvingChains = 0;
for (const ats of attemptsByStudent.values()) {
  const linked = ats.filter((a) => a.parent_attempt_id);
  if (linked.length >= 2) {
    const ordered = ats.slice().sort((a, b) =>
      +new Date(a.submitted_at) - +new Date(b.submitted_at)
    );
    const first = ordered[0].score / Math.max(1, ordered[0].question_count);
    const last = ordered[ordered.length - 1].score /
      Math.max(1, ordered[ordered.length - 1].question_count);
    const roots = new Set(
      ats.map((a) => a.parent_attempt_id ? "child" : a.id),
    );
    if (
      last - first >= 0.2 &&
      [...roots].filter((r) => r !== "child").length === 1
    ) {
      improvingChains++;
    }
  }
}
check(
  improvingChains === 1,
  `exactly one visible improvement arc across one chain (got ${improvingChains})`,
);

// ---- 4. heatmap spread ----
const chapterAcc = new Map<string, Acc>();
for (const r of revise) {
  const c = classOf.get(r.attempts.student_id);
  if (!c) continue;
  const key = `${c.id}|${r.micro_skills.chapter_id}`;
  const a = chapterAcc.get(key) ?? { correct: 0, total: 0 };
  a.total++;
  if (r.is_correct) a.correct++;
  chapterAcc.set(key, a);
}
const bands = new Set<string>();
for (const a of chapterAcc.values()) {
  const p = a.correct / a.total;
  bands.add(p >= 0.75 ? "green" : p >= 0.5 ? "amber" : "red");
}
check(
  bands.size >= 2,
  `heatmap shows a spread of bands: {${[...bands].join(", ")}}`,
);

console.log(
  `\n${
    pass
      ? "SHAPE LANDED"
      : "SHAPE MISMATCH — adjust the seed, not the analytics"
  }`,
);
if (!pass) Deno.exit(1);
