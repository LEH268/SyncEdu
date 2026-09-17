import { assertAlmostEquals } from "@std/assert";
import { admin, createTestSchool } from "./harness.ts";

Deno.test("the SQL formula matches the Dart formula on the same rows", async () => {
  const school = await createTestSchool("parity");
  try {
    const db = admin();
    const subjectId = crypto.randomUUID();
    const chapterId = crypto.randomUUID();
    const skillId = crypto.randomUUID();

    await db.from("subjects").insert({
      id: subjectId, school_id: school.id, name: "Mathematics", chapter_count: 1,
    });
    await db.from("chapters").insert({
      id: chapterId, school_id: school.id, subject_id: subjectId,
      ordinal: 1, title: "Quadratics",
    });
    await db.from("micro_skills").insert({
      id: skillId, school_id: school.id, chapter_id: chapterId,
      slug: "quad-factorise", label: "Factorise", ordinal: 1,
    });

    // Two attempts: one 14 days old and wrong, one now and right.
    const fourteenDaysAgo = new Date(Date.now() - 14 * 86400_000).toISOString();

    for (const [when, correct] of [[fourteenDaysAgo, false], [new Date().toISOString(), true]] as const) {
      const attemptId = crypto.randomUUID();
      await db.from("attempts").insert({
        id: attemptId, school_id: school.id, student_id: school.studentRowId,
        chapter_ids: [chapterId], mode: "revise", attempt_number: 1,
        question_count: 1, score: correct ? 1 : 0, submitted_at: when,
      });
      await db.from("attempt_items").insert({
        id: crypto.randomUUID(), school_id: school.id, attempt_id: attemptId,
        micro_skill_id: skillId, selected_index: 0, is_correct: correct, ordinal: 1,
      });
    }

    const { data } = await db.from("weaknesses").select("weight")
      .eq("student_id", school.studentRowId).eq("micro_skill_id", skillId).single();

    // Dart: decayed wrong 0.5, fresh right 1.0 -> 0.5 / 1.5 = 0.3333
    assertAlmostEquals(Number(data!.weight), 1 / 3, 0.02);
  } finally {
    await school.dispose();
  }
});
