import { assert, assertAlmostEquals, assertEquals } from "@std/assert";
import { admin, createTestSchool } from "./harness.ts";

async function chapterWithSkills(schoolId: string, slugs: string[]) {
  const db = admin();
  const subjectId = crypto.randomUUID();
  const chapterId = crypto.randomUUID();

  await db.from("subjects").insert({
    id: subjectId, school_id: schoolId, name: "Mathematics", chapter_count: 1,
  });
  await db.from("chapters").insert({
    id: chapterId, school_id: schoolId, subject_id: subjectId,
    ordinal: 1, title: "Quadratics",
  });

  const skills: Record<string, string> = {};
  for (const [index, slug] of slugs.entries()) {
    const id = crypto.randomUUID();
    await db.from("micro_skills").insert({
      id, school_id: schoolId, chapter_id: chapterId,
      slug, label: slug, ordinal: index + 1,
    });
    skills[slug] = id;
  }
  return { chapterId, skills };
}

async function recordAttempt(
  schoolId: string,
  studentRowId: string,
  chapterId: string,
  items: Array<{ skillId: string; correct: boolean }>,
  mode = "revise",
) {
  const db = admin();
  const attemptId = crypto.randomUUID();

  await db.from("attempts").insert({
    id: attemptId, school_id: schoolId, student_id: studentRowId,
    chapter_ids: [chapterId], mode, attempt_number: 1,
    question_count: items.length,
    score: items.filter((i) => i.correct).length,
    submitted_at: new Date().toISOString(),
  });

  await db.from("attempt_items").insert(items.map((item, index) => ({
    id: crypto.randomUUID(), school_id: schoolId, attempt_id: attemptId,
    micro_skill_id: item.skillId, selected_index: 0,
    is_correct: item.correct, ordinal: index + 1,
  })));

  return attemptId;
}

Deno.test("wrong answers create weakness rows with source 'quiz'", async () => {
  const school = await createTestSchool("weakness");
  try {
    const { chapterId, skills } = await chapterWithSkills(
      school.id, ["quad-factorise", "quad-formula"],
    );

    await recordAttempt(school.id, school.studentRowId, chapterId, [
      { skillId: skills["quad-factorise"], correct: false },
      { skillId: skills["quad-factorise"], correct: false },
      { skillId: skills["quad-formula"], correct: true },
      { skillId: skills["quad-formula"], correct: true },
    ]);

    const { data } = await admin()
      .from("weaknesses").select("micro_skill_id, weight, source")
      .eq("student_id", school.studentRowId);

    const byId = new Map(data!.map((w) => [w.micro_skill_id, w]));
    assert(byId.has(skills["quad-factorise"]), "a missed skill must be recorded");
    assertEquals(byId.get(skills["quad-factorise"])!.source, "quiz");
    assertAlmostEquals(byId.get(skills["quad-factorise"])!.weight, 1.0, 0.01);

    // A fully-correct skill either has no row or a zero weight; either way it
    // must not bias generation.
    const formula = byId.get(skills["quad-formula"]);
    assert(formula === undefined || formula.weight < 0.01);
  } finally {
    await school.dispose();
  }
});

Deno.test("weight is the error rate, so improvement lowers it", async () => {
  const school = await createTestSchool("improve");
  try {
    const { chapterId, skills } = await chapterWithSkills(school.id, ["quad-factorise"]);
    const skill = skills["quad-factorise"];

    await recordAttempt(school.id, school.studentRowId, chapterId, [
      { skillId: skill, correct: false },
      { skillId: skill, correct: false },
    ]);
    const { data: first } = await admin()
      .from("weaknesses").select("weight")
      .eq("student_id", school.studentRowId).eq("micro_skill_id", skill).single();

    await recordAttempt(school.id, school.studentRowId, chapterId, [
      { skillId: skill, correct: true },
      { skillId: skill, correct: true },
      { skillId: skill, correct: true },
      { skillId: skill, correct: true },
      { skillId: skill, correct: true },
      { skillId: skill, correct: true },
    ]);
    const { data: second } = await admin()
      .from("weaknesses").select("weight")
      .eq("student_id", school.studentRowId).eq("micro_skill_id", skill).single();

    assert(
      second!.weight < first!.weight,
      `weight should fall after improvement: ${first!.weight} -> ${second!.weight}`,
    );
  } finally {
    await school.dispose();
  }
});

Deno.test("quiz and exam weaknesses are separate rows on the same skill", async () => {
  const school = await createTestSchool("sources");
  try {
    const { chapterId, skills } = await chapterWithSkills(school.id, ["quad-factorise"]);
    const skill = skills["quad-factorise"];

    await recordAttempt(school.id, school.studentRowId, chapterId, [
      { skillId: skill, correct: false },
    ]);

    await admin().from("weaknesses").insert({
      id: crypto.randomUUID(), school_id: school.id,
      student_id: school.studentRowId, micro_skill_id: skill,
      weight: 0.8, source: "exam",
    });

    const { data } = await admin()
      .from("weaknesses").select("source")
      .eq("student_id", school.studentRowId).eq("micro_skill_id", skill);

    // Keeping the sources apart is what lets the console show *why* a skill
    // is flagged, and what makes the exam-paper requirement testable.
    assertEquals(data!.length, 2);
    assertEquals(data!.map((w) => w.source).sort(), ["exam", "quiz"]);
  } finally {
    await school.dispose();
  }
});

Deno.test("mode is stored on the attempt and survives a schedule change", async () => {
  const school = await createTestSchool("frozen");
  try {
    const { chapterId, skills } = await chapterWithSkills(school.id, ["quad-factorise"]);
    const attemptId = await recordAttempt(
      school.id, school.studentRowId, chapterId,
      [{ skillId: skills["quad-factorise"], correct: true }],
      "prep",
    );

    // The teacher later backdates the chapter as taught.
    const classId = crypto.randomUUID();
    await admin().from("classes").insert({
      id: classId, school_id: school.id, name: "4 Amanah", year_level: 4,
    });
    await admin().from("class_chapter_sched").insert({
      id: crypto.randomUUID(), school_id: school.id,
      class_id: classId, chapter_id: chapterId, taught_on: "2026-01-01",
    });

    const { data } = await admin()
      .from("attempts").select("mode").eq("id", attemptId).single();

    // Reclassifying history would silently change a heatmap someone has
    // already read.
    assertEquals(data!.mode, "prep");
  } finally {
    await school.dispose();
  }
});

Deno.test("a student cannot read another student's attempts", async () => {
  const school = await createTestSchool("attempt-privacy");
  try {
    const { chapterId, skills } = await chapterWithSkills(school.id, ["quad-factorise"]);

    // A second student in the same school.
    const otherProfile = crypto.randomUUID();
    const { data: created } = await admin().auth.admin.createUser({
      email: `other-${crypto.randomUUID()}@test.syncedu.invalid`,
      password: "seam-Test-Password-1!", email_confirm: true,
    });
    await admin().from("profiles").insert({
      id: created.user!.id, school_id: school.id, role: "student",
      full_name: "Other", email: created.user!.email!,
    });
    const otherStudentRow = crypto.randomUUID();
    await admin().from("students").insert({
      id: otherStudentRow, school_id: school.id, profile_id: created.user!.id,
    });

    await recordAttempt(school.id, otherStudentRow, chapterId, [
      { skillId: skills["quad-factorise"], correct: false },
    ]);

    const { data } = await school.student.client.from("attempts").select("id");
    assertEquals(data!.length, 0, "another student's attempts must be invisible");

    await admin().auth.admin.deleteUser(created.user!.id);
    void otherProfile;
  } finally {
    await school.dispose();
  }
});

Deno.test("a teacher reads attempts for students in classes they teach", async () => {
  const school = await createTestSchool("teacher-reads");
  try {
    const { chapterId, skills } = await chapterWithSkills(school.id, ["quad-factorise"]);

    const classId = crypto.randomUUID();
    const { data: subject } = await admin()
      .from("subjects").select("id").eq("school_id", school.id).single();

    await admin().from("classes").insert({
      id: classId, school_id: school.id, name: "4 Amanah", year_level: 4,
    });
    await admin().from("class_subjects").insert({
      id: crypto.randomUUID(), school_id: school.id, class_id: classId,
      subject_id: subject!.id, teacher_id: school.teacher.id,
    });
    await admin().from("students")
      .update({ class_id: classId }).eq("id", school.studentRowId);

    await recordAttempt(school.id, school.studentRowId, chapterId, [
      { skillId: skills["quad-factorise"], correct: false },
    ]);

    const { data } = await school.teacher.client.from("attempts").select("id");
    assertEquals(data!.length, 1);
  } finally {
    await school.dispose();
  }
});
