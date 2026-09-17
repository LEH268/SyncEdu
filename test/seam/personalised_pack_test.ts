import { assert, assertEquals } from "@std/assert";
import { handler } from "../../supabase/functions/generate-personalised-pack/handler.ts";
import { admin, createTestSchool } from "./harness.ts";

async function call(token: string, body: Record<string, unknown>) {
  const response = await handler(
    new Request("http://local/generate-personalised-pack", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${token}`,
        "content-type": "application/json",
      },
      body: JSON.stringify(body),
    }),
  );
  return { status: response.status, body: await response.json() };
}

async function seedChapter(school: Awaited<ReturnType<typeof createTestSchool>>) {
  const db = admin();
  const subjectId = crypto.randomUUID();
  const chapterId = crypto.randomUUID();
  const skillIds = [crypto.randomUUID(), crypto.randomUUID(), crypto.randomUUID()];

  await db.from("subjects").insert({
    id: subjectId, school_id: school.id, name: "Mathematics", chapter_count: 1,
  });
  await db.from("chapters").insert({
    id: chapterId, school_id: school.id, subject_id: subjectId,
    ordinal: 1, title: "Quadratic Equations",
  });
  await db.from("micro_skills").insert([
    { id: skillIds[0], school_id: school.id, chapter_id: chapterId, slug: "quad-factorise", label: "Factorise", ordinal: 1 },
    { id: skillIds[1], school_id: school.id, chapter_id: chapterId, slug: "quad-formula", label: "Use the formula", ordinal: 2 },
    { id: skillIds[2], school_id: school.id, chapter_id: chapterId, slug: "quad-discriminant", label: "Discriminant", ordinal: 3 },
  ]);

  return { chapterId, skillIds };
}

Deno.test({
  name: "a personalised pack targets the student's weak skills",
  ignore: Deno.env.get("RUN_MODEL_TESTS") !== "1",
  fn: async () => {
    const school = await createTestSchool("pp-weak");
    try {
      const db = admin();
      const { chapterId, skillIds } = await seedChapter(school);

      // Make the student very weak on the first skill: an old wrong attempt.
      const attemptId = crypto.randomUUID();
      await db.from("attempts").insert({
        id: attemptId, school_id: school.id, student_id: school.studentRowId,
        chapter_ids: [chapterId], mode: "revise", attempt_number: 1,
        question_count: 1, score: 0, submitted_at: new Date().toISOString(),
      });
      await db.from("attempt_items").insert({
        id: crypto.randomUUID(), school_id: school.id, attempt_id: attemptId,
        micro_skill_id: skillIds[0], selected_index: 0, is_correct: false, ordinal: 1,
      });

      const { data: { session } } = await school.student.client.auth.getSession();
      const result = await call(session!.access_token, {
        studentId: school.studentRowId,
        chapterIds: [chapterId],
        count: 6,
      });

      assertEquals(result.status, 200);
      assert(result.body.count > 0, "expected at least one generated question");

      const { data: written } = await db.from("questions")
        .select("micro_skill_id")
        .eq("for_student_id", school.studentRowId)
        .eq("provenance", "personalised");

      const weakCount = (written ?? []).filter((q) => q.micro_skill_id === skillIds[0]).length;
      assert(
        weakCount >= (written?.length ?? 0) / 2,
        `expected most questions to target the weak skill, got ${weakCount}/${written?.length}`,
      );
    } finally {
      await school.dispose();
    }
  },
});

Deno.test({
  name: "a student with no weaknesses still receives ordinary content",
  ignore: Deno.env.get("RUN_MODEL_TESTS") !== "1",
  fn: async () => {
    const school = await createTestSchool("pp-empty");
    try {
      const { chapterId } = await seedChapter(school);

      const { data: { session } } = await school.student.client.auth.getSession();
      const result = await call(session!.access_token, {
        studentId: school.studentRowId,
        chapterIds: [chapterId],
        count: 6,
      });

      assertEquals(result.status, 200);
      assert(result.body.count > 0, "expected a non-empty pack with no error");
    } finally {
      await school.dispose();
    }
  },
});

Deno.test("another student's token cannot request a pack for someone else", async () => {
  const school = await createTestSchool("pp-auth");
  const other = await createTestSchool("pp-auth-other");
  try {
    const { chapterId } = await seedChapter(school);

    const { data: { session } } = await other.student.client.auth.getSession();
    const result = await call(session!.access_token, {
      studentId: school.studentRowId,
      chapterIds: [chapterId],
      count: 6,
    });

    assertEquals(result.status, 403);
  } finally {
    await school.dispose();
    await other.dispose();
  }
});
