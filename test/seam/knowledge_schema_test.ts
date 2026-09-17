import { assert, assertEquals } from "@std/assert";
import { admin, createTestSchool } from "./harness.ts";

async function twoChapters(schoolId: string) {
  const db = admin();
  const subjectId = crypto.randomUUID();
  const a = crypto.randomUUID();
  const b = crypto.randomUUID();

  await db.from("subjects").insert({
    id: subjectId, school_id: schoolId, name: "Mathematics", chapter_count: 2,
  });
  await db.from("chapters").insert([
    { id: a, school_id: schoolId, subject_id: subjectId, ordinal: 1, title: "Quadratics" },
    { id: b, school_id: schoolId, subject_id: subjectId, ordinal: 2, title: "Sets" },
  ]);
  return { subjectId, chapterA: a, chapterB: b };
}

async function addSkill(schoolId: string, chapterId: string, slug: string) {
  const id = crypto.randomUUID();
  const { error } = await admin().from("micro_skills").insert({
    id, school_id: schoolId, chapter_id: chapterId,
    slug, label: slug, ordinal: 1,
  });
  assertEquals(error, null);
  return id;
}

Deno.test("a question citing its own chapter's micro-skill is accepted", async () => {
  const school = await createTestSchool("fk-ok");
  try {
    const { chapterA } = await twoChapters(school.id);
    const skillId = await addSkill(school.id, chapterA, "quad-factorise");

    const { error } = await admin().from("questions").insert({
      id: crypto.randomUUID(), school_id: school.id,
      chapter_id: chapterA, micro_skill_id: skillId,
      difficulty: 2, stem: "Solve x^2+5x+6=0",
      options: ["-2 and -3", "2 and 3", "-1 and -6", "1 and 6"],
      correct_index: 0, provenance: "pool",
    });
    assertEquals(error, null);
  } finally {
    await school.dispose();
  }
});

Deno.test("a question citing ANOTHER chapter's micro-skill is refused by the database",
  async () => {
    // This is the guarantee the whole analytic layer rests on. The enum in the
    // model's response schema is the first line of defence; this is the one
    // that cannot be talked out of.
    const school = await createTestSchool("fk-cross");
    try {
      const { chapterA, chapterB } = await twoChapters(school.id);
      const skillInB = await addSkill(school.id, chapterB, "sets-union");

      const { error } = await admin().from("questions").insert({
        id: crypto.randomUUID(), school_id: school.id,
        chapter_id: chapterA,          // chapter A
        micro_skill_id: skillInB,      // skill from chapter B
        difficulty: 2, stem: "Mismatched",
        options: ["a", "b", "c", "d"], correct_index: 0, provenance: "pool",
      });

      assert(error !== null, "the composite FK must refuse a cross-chapter citation");
      assert(
        error!.message.toLowerCase().includes("foreign key") ||
          error!.code === "23503",
        `expected a foreign key violation, got: ${error!.message}`,
      );
    } finally {
      await school.dispose();
    }
  });

Deno.test("a micro-skill slug is unique within its chapter but reusable across chapters",
  async () => {
    const school = await createTestSchool("slug-scope");
    try {
      const { chapterA, chapterB } = await twoChapters(school.id);
      await addSkill(school.id, chapterA, "definitions");

      const { error: duplicate } = await admin().from("micro_skills").insert({
        id: crypto.randomUUID(), school_id: school.id,
        chapter_id: chapterA, slug: "definitions", label: "x", ordinal: 2,
      });
      assert(duplicate !== null, "a slug cannot repeat within one chapter");

      const { error: otherChapter } = await admin().from("micro_skills").insert({
        id: crypto.randomUUID(), school_id: school.id,
        chapter_id: chapterB, slug: "definitions", label: "x", ordinal: 1,
      });
      assertEquals(otherChapter, null, "the same slug in another chapter is fine");
    } finally {
      await school.dispose();
    }
  });

Deno.test("once locked, a chapter accepts no new micro-skills", async () => {
  const school = await createTestSchool("locked");
  try {
    const { chapterA } = await twoChapters(school.id);
    await addSkill(school.id, chapterA, "quad-factorise");

    await admin().from("chapters")
      .update({ micro_skills_locked_at: new Date().toISOString() })
      .eq("id", chapterA);

    const { error } = await admin().from("micro_skills").insert({
      id: crypto.randomUUID(), school_id: school.id,
      chapter_id: chapterA, slug: "quad-late-arrival", label: "x", ordinal: 9,
    });

    // Re-ingesting the same document must not silently widen the vocabulary.
    assert(error !== null, "a locked chapter must refuse a new micro-skill");
  } finally {
    await school.dispose();
  }
});

Deno.test("difficulty is constrained to the three bands", async () => {
  const school = await createTestSchool("bands");
  try {
    const { chapterA } = await twoChapters(school.id);
    const skillId = await addSkill(school.id, chapterA, "quad-factorise");

    const { error } = await admin().from("questions").insert({
      id: crypto.randomUUID(), school_id: school.id,
      chapter_id: chapterA, micro_skill_id: skillId,
      difficulty: 4, stem: "Out of band",
      options: ["a", "b", "c", "d"], correct_index: 0, provenance: "pool",
    });
    assert(error !== null, "difficulty must be 1, 2 or 3");
  } finally {
    await school.dispose();
  }
});

Deno.test("correct_index must address one of the supplied options", async () => {
  const school = await createTestSchool("index");
  try {
    const { chapterA } = await twoChapters(school.id);
    const skillId = await addSkill(school.id, chapterA, "quad-factorise");

    const { error } = await admin().from("questions").insert({
      id: crypto.randomUUID(), school_id: school.id,
      chapter_id: chapterA, micro_skill_id: skillId,
      difficulty: 1, stem: "Bad index",
      options: ["a", "b", "c", "d"], correct_index: 7, provenance: "pool",
    });
    assert(error !== null, "correct_index must fall inside options");
  } finally {
    await school.dispose();
  }
});
