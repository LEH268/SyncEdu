import { assert, assertEquals } from "@std/assert";
import { handler } from "../../supabase/functions/analyse-exam-paper/handler.ts";
import { admin, createTestSchool } from "./harness.ts";

type School = Awaited<ReturnType<typeof createTestSchool>>;

async function call(token: string, body: Record<string, unknown>) {
  const response = await handler(
    new Request("http://local/analyse-exam-paper", {
      method: "POST",
      headers: { "Authorization": `Bearer ${token}`, "content-type": "application/json" },
      body: JSON.stringify(body),
    }),
  );
  return { status: response.status, body: await response.json().catch(() => ({})) };
}

/// Puts the school's student in a class the school's teacher teaches, and
/// ingests one chapter's micro-skills.
async function seed(school: School) {
  const db = admin();
  const subjectId = crypto.randomUUID();
  const chapterId = crypto.randomUUID();
  const classId = crypto.randomUUID();
  const skillIds = [crypto.randomUUID(), crypto.randomUUID(), crypto.randomUUID()];

  await db.from("subjects").insert({
    id: subjectId, school_id: school.id, name: "Mathematics", chapter_count: 1,
  });
  await db.from("chapters").insert({
    id: chapterId, school_id: school.id, subject_id: subjectId, ordinal: 1,
    title: "Number Bases",
  });
  await db.from("classes").insert({
    id: classId, school_id: school.id, name: "4 Cendekia", year_level: 4,
  });
  await db.from("class_subjects").insert({
    id: crypto.randomUUID(), school_id: school.id, class_id: classId,
    subject_id: subjectId, teacher_id: school.teacher.id,
  });
  await db.from("students").update({ class_id: classId }).eq("id", school.studentRowId);
  await db.from("micro_skills").insert([
    { id: skillIds[0], school_id: school.id, chapter_id: chapterId, slug: "base-convert", label: "Convert between bases", description: "e.g. base 2 to base 10", ordinal: 1 },
    { id: skillIds[1], school_id: school.id, chapter_id: chapterId, slug: "base-arithmetic", label: "Arithmetic in a base", description: "Add and subtract in base n", ordinal: 2 },
    { id: skillIds[2], school_id: school.id, chapter_id: chapterId, slug: "base-place-value", label: "Place value", description: "Digit weights in base n", ordinal: 3 },
  ]);

  return { chapterId, classId, skillIds };
}

async function uploadPaper(school: School, chapterId: string) {
  const db = admin();
  const path = `${school.id}/${crypto.randomUUID()}.pdf`;
  await db.storage.from("exam-papers").upload(
    path,
    new Blob([new Uint8Array([37, 80, 68, 70])], { type: "application/pdf" }),
    { contentType: "application/pdf" },
  );
  const id = crypto.randomUUID();
  await db.from("exam_papers").insert({
    id, school_id: school.id, student_id: school.studentRowId, chapter_id: chapterId,
    storage_path: path, uploaded_by: school.teacher.id,
  });
  return { id, path };
}

Deno.test("a student's token cannot upload an exam paper", async () => {
  const school = await createTestSchool("ep-student");
  try {
    const { chapterId } = await seed(school);
    const { error } = await school.student.client.from("exam_papers").insert({
      id: crypto.randomUUID(), school_id: school.id, student_id: school.studentRowId,
      chapter_id: chapterId, storage_path: "x/y.pdf", uploaded_by: school.student.id,
    });
    assert(error !== null, "students never submit files");
  } finally {
    await school.dispose();
  }
});

Deno.test("a teacher cannot upload for a student they do not teach", async () => {
  const school = await createTestSchool("ep-notmine");
  try {
    const { chapterId } = await seed(school);
    // Detach the student from the class this teacher teaches.
    await admin().from("students").update({ class_id: null }).eq("id", school.studentRowId);

    const { error } = await school.teacher.client.from("exam_papers").insert({
      id: crypto.randomUUID(), school_id: school.id, student_id: school.studentRowId,
      chapter_id: chapterId, storage_path: "x/y.pdf", uploaded_by: school.teacher.id,
    });
    assert(error !== null, "a teacher may only upload for a student in a class they teach");
  } finally {
    await school.dispose();
  }
});

Deno.test("a fresh paper is pending and flips to analysed once processed", async () => {
  const school = await createTestSchool("ep-pending");
  try {
    const { chapterId } = await seed(school);
    const { id } = await uploadPaper(school, chapterId);

    const { data: before } = await admin().from("exam_papers")
      .select("analysis_status").eq("id", id).single();
    assertEquals(before!.analysis_status, "pending");
  } finally {
    await school.dispose();
  }
});

Deno.test({
  name: "analysis maps errors onto the chapter's EXISTING micro-skill slugs",
  ignore: Deno.env.get("RUN_MODEL_TESTS") !== "1",
  fn: async () => {
    const school = await createTestSchool("ep-model");
    try {
      const { chapterId, skillIds } = await seed(school);
      const { id } = await uploadPaper(school, chapterId);

      // Seed a quiz-sourced weakness on the first skill so we can prove the
      // exam row does not clobber it.
      const attemptId = crypto.randomUUID();
      await admin().from("attempts").insert({
        id: attemptId, school_id: school.id, student_id: school.studentRowId,
        chapter_ids: [chapterId], mode: "revise", attempt_number: 1,
        question_count: 1, score: 0, submitted_at: new Date().toISOString(),
      });
      await admin().from("attempt_items").insert({
        id: crypto.randomUUID(), school_id: school.id, attempt_id: attemptId,
        micro_skill_id: skillIds[0], selected_index: 0, is_correct: false, ordinal: 1,
      });

      const { data: { session } } = await school.teacher.client.auth.getSession();
      const result = await call(session!.access_token, { examPaperId: id });
      assertEquals(result.status, 200);

      const allowed = new Set(skillIds);
      const { data: examRows } = await admin().from("weaknesses")
        .select("micro_skill_id, source")
        .eq("student_id", school.studentRowId).eq("source", "exam");
      assert((examRows ?? []).length > 0, "expected exam-sourced weakness rows");
      assert((examRows ?? []).every((w) => allowed.has(w.micro_skill_id)));

      const { data: quizRows } = await admin().from("weaknesses")
        .select("micro_skill_id").eq("student_id", school.studentRowId).eq("source", "quiz");
      assert((quizRows ?? []).length > 0, "the quiz weakness must survive");

      const { data: paper } = await admin().from("exam_papers")
        .select("analysis_status").eq("id", id).single();
      assertEquals(paper!.analysis_status, "analysed");
    } finally {
      await school.dispose();
    }
  },
});
