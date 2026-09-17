// Seed four weeks of attempt history against the REAL ingested micro-skills.
//
// Weakness rows are DERIVED. Writing them directly would put numbers on the
// charts that the arithmetic in syncedu_core cannot reproduce -- the exact
// failure the spec calls silent, plausible and unrecoverable.
//
// Every insert here goes through `attempts` / `attempt_items` and lets
// `public.recompute_weaknesses` (the attempt_items trigger) do its job.
//
// Elapsed time is the ONLY thing this script fabricates. Every chapter,
// micro-skill slug and pool question it references was genuinely ingested in
// Phase 3. The structure it aims for mirrors
// packages/syncedu_core/lib/src/testing/history_shape.dart exactly:
//
//   * class 0 carries a genuine deficit on one micro-skill (~50% of the class)
//   * three at-risk students, one each for low_mastery / inactive / declining
//   * one student (class 2, slot 0) improves across a single retry chain
//   * class 0 is scheduled five chapters ahead; class 2 only two
//
// Usage:
//   deno run --allow-all --env-file=.env scripts/seed_history.ts
//
// Idempotent: re-running tombstones the previously seeded attempts for the
// school and rebuilds them, so the derived weaknesses converge on the same
// values. Disclosed, not presented as organic history.

import { createClient } from "@supabase/supabase-js";

const url = Deno.env.get("SUPABASE_URL")!;
const db = createClient(url, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!, {
  auth: { persistSession: false },
});

const PASSWORD = "SyncEdu-Demo-1!";
const DOMAIN = "demo.syncedu.invalid";
const WEEKS = 4;
const CLASS_COUNT = 3;
const STUDENTS_PER_CLASS = 12;
const TEACHER_COUNT = 2;
const NOW = new Date();

// ── deterministic RNG (mulberry32) ────────────────────────────────────────
function rng(seed: number): () => number {
  let a = seed >>> 0;
  return () => {
    a |= 0;
    a = (a + 0x6d2b79f5) | 0;
    let x = Math.imul(a ^ (a >>> 15), 1 | a);
    x = (x + Math.imul(x ^ (x >>> 7), 61 | x)) ^ x;
    return ((x ^ (x >>> 14)) >>> 0) / 4294967296;
  };
}
const rand = rng(0x5ec7ed0);
const pick = <T>(xs: T[]): T => xs[Math.floor(rand() * xs.length)];
const uuid = () => crypto.randomUUID();
const daysAgo = (d: number) =>
  new Date(NOW.getTime() - d * 86400_000).toISOString();
const dateAgo = (d: number) => daysAgo(d).slice(0, 10);

// ── 1. resolve the ingested school ────────────────────────────────────────
const wantSchool = Deno.env.get("SEED_SCHOOL_ID");
const { data: schools, error: schoolErr } = await db
  .from("schools").select("id, name, created_at")
  .order("created_at", { ascending: false });
if (schoolErr) throw schoolErr;

let schoolId: string | undefined = wantSchool;
if (!schoolId) {
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
if (!schoolId) {
  throw new Error(
    "no school has >=8 ready materials; run scripts/ingest_seed_content.ts first",
  );
}
console.log(`seeding history into school ${schoolId}`);

await db.from("schools").update({
  education_level: "secondary",
  content_language: "en",
}).eq("id", schoolId);

// ── 2. load the real academic content ─────────────────────────────────────
const { data: subjects } = await db.from("subjects")
  .select("id, name").eq("school_id", schoolId).order("name");
const { data: chapters } = await db.from("chapters")
  .select("id, subject_id, ordinal, title")
  .eq("school_id", schoolId).order("ordinal");
const { data: skills } = await db.from("micro_skills")
  .select("id, chapter_id, ordinal, slug").eq("school_id", schoolId)
  .order("ordinal");
const { data: pool } = await db.from("questions")
  .select("id, chapter_id, micro_skill_id, difficulty, correct_index")
  .eq("school_id", schoolId).eq("provenance", "pool");

if (
  !subjects?.length || !chapters?.length || !skills?.length || !pool?.length
) {
  throw new Error("academic content missing; ingestion is not complete");
}

const skillsByChapter = new Map<string, typeof skills>();
for (const s of skills) {
  (skillsByChapter.get(s.chapter_id) ??
    skillsByChapter.set(s.chapter_id, []).get(s.chapter_id)!)
    .push(s);
}
for (const list of skillsByChapter.values()) {
  list.sort((a, b) => a.ordinal - b.ordinal);
}

const questionsBySkill = new Map<string, typeof pool>();
for (const q of pool) {
  (questionsBySkill.get(q.micro_skill_id) ??
    questionsBySkill.set(q.micro_skill_id, []).get(q.micro_skill_id)!).push(q);
}

const chaptersBySubject = new Map<string, typeof chapters>();
for (const c of chapters) {
  (chaptersBySubject.get(c.subject_id) ??
    chaptersBySubject.set(c.subject_id, []).get(c.subject_id)!).push(c);
}
for (const list of chaptersBySubject.values()) {
  list.sort((a, b) => a.ordinal - b.ordinal);
}

// ── 3. provision teachers + students (reuse where present) ────────────────
async function ensureUser(
  email: string,
  role: "teacher" | "student",
  fullName: string,
): Promise<string> {
  const existing = await db.auth.admin.listUsers({ page: 1, perPage: 1000 });
  const found = existing.data.users.find((u) => u.email === email);
  let id = found?.id;
  if (!id) {
    const { data, error } = await db.auth.admin.createUser({
      email,
      password: PASSWORD,
      email_confirm: true,
    });
    if (error) throw error;
    id = data.user!.id;
  }
  await db.from("profiles").upsert({
    id,
    school_id: schoolId,
    role,
    full_name: fullName,
    email,
  });
  if (role === "student") {
    const { data: st } = await db.from("students")
      .select("id").eq("profile_id", id).maybeSingle();
    if (!st) {
      await db.from("students").insert({
        id: uuid(),
        school_id: schoolId,
        profile_id: id,
        pre_admission_completed_at: daysAgo(WEEKS * 7 + 3),
      });
    }
  }
  return id;
}

const teacherIds: string[] = [];
for (let i = 0; i < TEACHER_COUNT; i++) {
  teacherIds.push(
    await ensureUser(
      `teacher${i + 1}@${DOMAIN}`,
      "teacher",
      `Demo Teacher ${i + 1}`,
    ),
  );
}

const STYLES = ["V", "A", "R", "K"] as const;
const classes: { id: string; slot: number }[] = [];
for (let c = 0; c < CLASS_COUNT; c++) {
  const { data: existing } = await db.from("classes")
    .select("id").eq("school_id", schoolId).eq("name", `4 Seed-${c + 1}`)
    .maybeSingle();
  const id = existing?.id ?? uuid();
  if (!existing) {
    await db.from("classes").insert({
      id,
      school_id: schoolId,
      name: `4 Seed-${c + 1}`,
      year_level: 4,
      target_learning_style: STYLES[c % STYLES.length],
    });
  }
  classes.push({ id, slot: c });

  // Both subjects taught to every class; teachers split across classes.
  for (const subj of subjects) {
    await db.from("class_subjects").upsert({
      id: uuid(),
      school_id: schoolId,
      class_id: id,
      subject_id: subj.id,
      teacher_id: teacherIds[c % TEACHER_COUNT],
    }, { onConflict: "class_id,subject_id", ignoreDuplicates: true });
  }
}

// students, 12 per class
type Student = { id: string; classId: string; classSlot: number; slot: number };
const students: Student[] = [];
for (const cls of classes) {
  for (let s = 0; s < STUDENTS_PER_CLASS; s++) {
    const n = cls.slot * STUDENTS_PER_CLASS + s + 1;
    const profileId = await ensureUser(
      `student${n}@${DOMAIN}`,
      "student",
      `Demo Student ${n}`,
    );
    const { data: st } = await db.from("students")
      .select("id").eq("profile_id", profileId).single();
    await db.from("students").update({ class_id: cls.id }).eq("id", st!.id);
    students.push({
      id: st!.id,
      classId: cls.id,
      classSlot: cls.slot,
      slot: s,
    });
  }
}
console.log(
  `${teacherIds.length} teachers, ${students.length} students, ${classes.length} classes`,
);

// ── 4. per-class schedule: class 0 ahead, class 2 behind ──────────────────
const taughtCountForClass = (slot: number) =>
  slot === 0 ? 5 : slot === 2 ? 2 : 3;

// classId -> chapterId -> taught_on Date (only taught chapters present)
const taught = new Map<string, Map<string, Date>>();
for (const cls of classes) {
  const perChapter = new Map<string, Date>();
  const n = taughtCountForClass(cls.slot);
  for (const subj of subjects) {
    const chs = chaptersBySubject.get(subj.id)!;
    for (let i = 0; i < Math.min(n, chs.length); i++) {
      // Spread teaching across the 4-week window, earliest chapters first.
      const daysBack = WEEKS * 7 - Math.floor((i / n) * (WEEKS * 7 - 3)) - 3;
      const on = new Date(NOW.getTime() - daysBack * 86400_000);
      perChapter.set(chs[i].id, on);
      await db.from("class_chapter_sched").upsert({
        id: uuid(),
        school_id: schoolId,
        class_id: cls.id,
        chapter_id: chs[i].id,
        taught_on: on.toISOString().slice(0, 10),
      }, { onConflict: "class_id,chapter_id", ignoreDuplicates: false });
    }
  }
  taught.set(cls.id, perChapter);
}

// ── 5. wipe any prior seeded attempts for a clean re-run ──────────────────
const studentIds = students.map((s) => s.id);
const { data: priorAttempts } = await db.from("attempts")
  .select("id").in("student_id", studentIds);
if (priorAttempts?.length) {
  const ids = priorAttempts.map((a) => a.id);
  for (let i = 0; i < ids.length; i += 200) {
    await db.from("attempt_items").delete().in(
      "attempt_id",
      ids.slice(i, i + 200),
    );
  }
  for (let i = 0; i < ids.length; i += 200) {
    await db.from("attempts").delete().in("id", ids.slice(i, i + 200));
  }
  console.log(`cleared ${ids.length} prior attempts`);
}

// ── 6. the shape ─────────────────────────────────────────────────────────
// deficit: class 0, the 2nd micro-skill of its first taught Maths chapter.
const deficitClass = classes[0];
const mathSubject = subjects.find((s) => /math/i.test(s.name)) ?? subjects[0];
const deficitChapter = chaptersBySubject.get(mathSubject.id)![0];
const deficitSkill = (skillsByChapter.get(deficitChapter.id) ?? [])[1] ??
  (skillsByChapter.get(deficitChapter.id) ?? [])[0];

// at-risk students, by (classSlot, slot) — mirrors history_shape.dart
const lowMasteryKey = "1:9";
const inactiveKey = "1:10";
const decliningKey = "2:11";
const improvingKey = "2:0";
const keyOf = (s: Student) => `${s.classSlot}:${s.slot}`;
// the deficit-struggling half of class 0
const deficitStrugglers = new Set(
  students.filter((s) => s.classSlot === 0).slice(0, 6).map((s) => s.id),
);

// ── 7. generate attempts ─────────────────────────────────────────────────
type ItemRow = {
  id: string;
  school_id: string;
  attempt_id: string;
  question_id: string | null;
  micro_skill_id: string;
  selected_index: number | null;
  is_correct: boolean;
  ordinal: number;
};
const attemptRows: Record<string, unknown>[] = [];
const itemRows: ItemRow[] = [];

function emitAttempt(opts: {
  student: Student;
  chapterId: string;
  submittedDaysAgo: number;
  targetAccuracy: number;
  attemptNumber?: number;
  parentAttemptId?: string | null;
  questionCount?: number;
  onlySkillId?: string;
}): string {
  const attemptId = uuid();
  const chapterSkills = skillsByChapter.get(opts.chapterId) ?? [];
  const qCount = opts.questionCount ?? 5 + Math.floor(rand() * 3);
  let correct = 0;
  const items: ItemRow[] = [];
  for (let o = 0; o < qCount; o++) {
    const skill = opts.onlySkillId
      ? chapterSkills.find((s) => s.id === opts.onlySkillId) ??
        pick(chapterSkills)
      : pick(chapterSkills);
    const qs = questionsBySkill.get(skill.id) ?? [];
    const q = qs.length ? pick(qs) : null;
    const isCorrect = rand() < opts.targetAccuracy;
    if (isCorrect) correct++;
    items.push({
      id: uuid(),
      school_id: schoolId!,
      attempt_id: attemptId,
      question_id: q?.id ?? null,
      micro_skill_id: skill.id,
      selected_index: q
        ? (isCorrect ? q.correct_index : (q.correct_index + 1) % 4)
        : null,
      is_correct: isCorrect,
      ordinal: o,
    });
  }
  attemptRows.push({
    id: attemptId,
    school_id: schoolId,
    student_id: opts.student.id,
    chapter_ids: [opts.chapterId],
    mode: "revise",
    attempt_number: opts.attemptNumber ?? 1,
    parent_attempt_id: opts.parentAttemptId ?? null,
    question_count: qCount,
    score: correct,
    started_at: daysAgo(opts.submittedDaysAgo),
    submitted_at: daysAgo(opts.submittedDaysAgo),
  });
  itemRows.push(...items);
  return attemptId;
}

for (const student of students) {
  const k = keyOf(student);
  const taughtHere = taught.get(student.classId)!;
  const taughtChapters = [...taughtHere.entries()];

  // ---- special cases ----
  if (k === inactiveKey) {
    // Active only in the first ~2.5 weeks, nothing in the last 10 days.
    for (const [chId, on] of taughtChapters) {
      const since = Math.floor((NOW.getTime() - on.getTime()) / 86400_000);
      for (let d = since; d >= 11; d -= 4 + Math.floor(rand() * 3)) {
        emitAttempt({
          student,
          chapterId: chId,
          submittedDaysAgo: d,
          targetAccuracy: 0.6,
        });
      }
    }
    continue;
  }

  if (k === decliningKey) {
    // One chapter, three attempts, scores 85 -> 65 -> 45 (%).
    const chId = taughtChapters[0][0];
    const scores = [0.85, 0.65, 0.45];
    for (let i = 0; i < 3; i++) {
      emitAttempt({
        student,
        chapterId: chId,
        submittedDaysAgo: 18 - i * 6,
        targetAccuracy: scores[i],
        attemptNumber: i + 1,
        questionCount: 20,
      });
    }
    continue;
  }

  if (k === improvingKey) {
    // One retry chain of four attempts, 40 -> 55 -> 65 -> 78 (%).
    const chId = taughtChapters[0][0];
    const scores = [0.4, 0.55, 0.65, 0.78];
    let parent: string | null = null;
    for (let i = 0; i < 4; i++) {
      parent = emitAttempt({
        student,
        chapterId: chId,
        submittedDaysAgo: 22 - i * 5,
        targetAccuracy: scores[i],
        attemptNumber: i + 1,
        parentAttemptId: parent,
        questionCount: 20,
      });
    }
    // plus ordinary activity on the rest
    for (const [chId2, on] of taughtChapters.slice(1)) {
      const since = Math.floor((NOW.getTime() - on.getTime()) / 86400_000);
      emitAttempt({
        student,
        chapterId: chId2,
        submittedDaysAgo: Math.max(2, since - 3),
        targetAccuracy: 0.7,
      });
    }
    continue;
  }

  const lowMastery = k === lowMasteryKey;
  const baseAccuracy = lowMastery ? 0.4 : 0.6 + rand() * 0.25;

  // ---- ordinary students ----
  for (const [chId, on] of taughtChapters) {
    const since = Math.floor((NOW.getTime() - on.getTime()) / 86400_000);
    const runs = 1 + Math.floor(rand() * 3);
    for (let r = 0; r < runs; r++) {
      const submittedDaysAgo = Math.max(
        1,
        since - Math.floor((r / runs) * since) - Math.floor(rand() * 3),
      );
      let acc = baseAccuracy;
      // deficit: struggling half of class 0 on the deficit chapter, focused
      // on the deficit skill.
      const focusDeficit = chId === deficitChapter.id &&
        deficitStrugglers.has(student.id);
      emitAttempt({
        student,
        chapterId: chId,
        submittedDaysAgo,
        targetAccuracy: focusDeficit ? 0.35 : acc,
        onlySkillId: focusDeficit ? deficitSkill?.id : undefined,
      });
    }
  }

  // Make sure the non-struggling half of class 0 clears the bar on the
  // deficit skill so the proportion lands near 50%, not 100%.
  if (student.classSlot === 0 && !deficitStrugglers.has(student.id)) {
    emitAttempt({
      student,
      chapterId: deficitChapter.id,
      submittedDaysAgo: 4 + Math.floor(rand() * 6),
      targetAccuracy: 0.85,
      questionCount: 6,
      onlySkillId: deficitSkill?.id,
    });
  }
}

// ── 8. insert (attempts first, then items -> trigger derives weaknesses) ──
async function chunkInsert(table: string, rows: unknown[]) {
  for (let i = 0; i < rows.length; i += 200) {
    const { error } = await db.from(table).insert(rows.slice(i, i + 200));
    if (error) throw new Error(`${table}: ${error.message}`);
  }
}
await chunkInsert("attempts", attemptRows);
await chunkInsert("attempt_items", itemRows);

console.log(
  `inserted ${attemptRows.length} attempts, ${itemRows.length} items`,
);
console.log("weaknesses are now being derived by the attempt_items trigger.");
console.log("run scripts/verify_seed_shape.ts to confirm the shape landed.");
