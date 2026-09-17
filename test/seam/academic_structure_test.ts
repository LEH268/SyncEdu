import { assert, assertEquals } from "@std/assert";
import { admin, createTestSchool } from "./harness.ts";

async function buildCurriculum(schoolId: string, teacherId: string) {
  const db = admin();
  const subjectId = crypto.randomUUID();
  const classId = crypto.randomUUID();
  const chapterIds = [crypto.randomUUID(), crypto.randomUUID()];

  await db.from("subjects").insert({
    id: subjectId, school_id: schoolId, name: "Mathematics", chapter_count: 2,
  });
  await db.from("chapters").insert([
    { id: chapterIds[0], school_id: schoolId, subject_id: subjectId, ordinal: 1, title: "Quadratic Functions" },
    { id: chapterIds[1], school_id: schoolId, subject_id: subjectId, ordinal: 2, title: "Number Bases" },
  ]);
  await db.from("classes").insert({
    id: classId, school_id: schoolId, name: "4 Amanah",
    year_level: 4, target_learning_style: "V",
  });
  await db.from("class_subjects").insert({
    id: crypto.randomUUID(), school_id: schoolId,
    class_id: classId, subject_id: subjectId, teacher_id: teacherId,
  });

  return { subjectId, classId, chapterIds };
}

Deno.test("a chapter's ordinal is unique within its subject", async () => {
  const school = await createTestSchool("ordinal");
  try {
    const { subjectId } = await buildCurriculum(school.id, school.teacher.id);

    const { error } = await admin().from("chapters").insert({
      id: crypto.randomUUID(), school_id: school.id,
      subject_id: subjectId, ordinal: 1, title: "Duplicate",
    });
    assert(error !== null, "two chapters cannot share an ordinal in one subject");
  } finally {
    await school.dispose();
  }
});

Deno.test("a teacher sees only the classes they teach", async () => {
  const school = await createTestSchool("teaches");
  try {
    const mine = await buildCurriculum(school.id, school.teacher.id);

    // A second class in the same school, taught by nobody in this fixture.
    const otherClassId = crypto.randomUUID();
    await admin().from("classes").insert({
      id: otherClassId, school_id: school.id, name: "4 Bestari",
      year_level: 4, target_learning_style: "A",
    });

    const { data } = await school.teacher.client.from("classes").select("id");
    assertEquals(data!.map((c) => c.id), [mine.classId]);

    // An admin sees the whole school.
    const { data: asAdmin } = await school.admin.client.from("classes").select("id");
    assertEquals(asAdmin!.length, 2);
  } finally {
    await school.dispose();
  }
});

Deno.test("a schedule row classifies a chapter as taught or not", async () => {
  const school = await createTestSchool("schedule");
  try {
    const { classId, chapterIds } = await buildCurriculum(school.id, school.teacher.id);

    await admin().from("class_chapter_sched").insert([
      { id: crypto.randomUUID(), school_id: school.id, class_id: classId,
        chapter_id: chapterIds[0], taught_on: "2026-08-01" },
      { id: crypto.randomUUID(), school_id: school.id, class_id: classId,
        chapter_id: chapterIds[1], taught_on: null },
    ]);

    const { data } = await school.teacher.client
      .from("class_chapter_sched").select("chapter_id, taught_on")
      .eq("class_id", classId).order("taught_on", { nullsFirst: false });

    assertEquals(data!.length, 2);
    assertEquals(data!.filter((r) => r.taught_on !== null).length, 1);
  } finally {
    await school.dispose();
  }
});

Deno.test("a student can be assigned to a class", async () => {
  const school = await createTestSchool("assign");
  try {
    const { classId } = await buildCurriculum(school.id, school.teacher.id);

    const { error } = await admin().from("students")
      .update({ class_id: classId }).eq("id", school.studentRowId);
    assertEquals(error, null);

    const { data } = await school.student.client
      .from("students").select("class_id").eq("id", school.studentRowId).single();
    assertEquals(data!.class_id, classId);
  } finally {
    await school.dispose();
  }
});

Deno.test("a class_id from another school is rejected", async () => {
  const [a, b] = await Promise.all([
    createTestSchool("fk-a"),
    createTestSchool("fk-b"),
  ]);
  try {
    const other = await buildCurriculum(b.id, b.teacher.id);

    const { error } = await admin().from("students")
      .update({ class_id: other.classId }).eq("id", a.studentRowId);

    // The foreign key alone would allow this; the school check is what stops it.
    assert(error !== null, "a cross-school class assignment must be refused");
  } finally {
    await Promise.all([a.dispose(), b.dispose()]);
  }
});
