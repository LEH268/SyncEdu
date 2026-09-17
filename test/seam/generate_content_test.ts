import { assert, assertEquals } from "@std/assert";
import { handler } from "../../supabase/functions/generate-content/handler.ts";
import { admin, createTestSchool } from "./harness.ts";

async function call(token: string, body: Record<string, unknown>) {
  const response = await handler(
    new Request("http://local/generate-content", {
      method: "POST",
      headers: { "Authorization": `Bearer ${token}`, "content-type": "application/json" },
      body: JSON.stringify(body),
    }),
  );
  return { status: response.status, body: await response.json() };
}

async function seedChapter(school: Awaited<ReturnType<typeof createTestSchool>>) {
  const db = admin();
  const subjectId = crypto.randomUUID();
  const chapterId = crypto.randomUUID();
  const materialId = crypto.randomUUID();
  const skillIds = [crypto.randomUUID(), crypto.randomUUID(), crypto.randomUUID()];

  await db.from("subjects").insert({
    id: subjectId, school_id: school.id, name: "Biology", chapter_count: 1,
  });
  await db.from("chapters").insert({
    id: chapterId, school_id: school.id, subject_id: subjectId, ordinal: 1,
    title: "Cell Biology and Cell Organisation",
  });
  await db.from("materials").insert({
    id: materialId, school_id: school.id, chapter_id: chapterId,
    uploaded_by: school.teacher.id, storage_path: `${school.id}/notes.pdf`,
    mime_type: "application/pdf", original_filename: "notes.pdf",
    ingestion_status: "ready",
  });
  await db.from("micro_skills").insert([
    { id: skillIds[0], school_id: school.id, chapter_id: chapterId, slug: "cell-structure", label: "Cell structure", description: "Parts of a cell", ordinal: 1 },
    { id: skillIds[1], school_id: school.id, chapter_id: chapterId, slug: "organelle-function", label: "Organelle function", description: "What organelles do", ordinal: 2 },
    { id: skillIds[2], school_id: school.id, chapter_id: chapterId, slug: "cell-organisation", label: "Cell organisation", description: "Cells to systems", ordinal: 3 },
  ]);
  await db.from("knowledge_packs").insert({
    id: crypto.randomUUID(), school_id: school.id, chapter_id: chapterId,
    material_id: materialId,
    concepts: [{ name: "Nucleus", summary: "Controls the cell" }],
    worked_examples: [{ problem: "Name an organelle", solution: "Mitochondrion" }],
    model_version: "gemini-2.5-flash",
  });

  return { chapterId, skillIds };
}

Deno.test("a student cannot request content for another student", async () => {
  const school = await createTestSchool("gc-auth");
  const other = await createTestSchool("gc-auth-other");
  try {
    const { chapterId } = await seedChapter(school);
    const { data: { session } } = await other.student.client.auth.getSession();
    const result = await call(session!.access_token, {
      kind: "flashcards",
      chapterId,
      studentId: school.studentRowId,
    });
    assertEquals(result.status, 403);
  } finally {
    await school.dispose();
    await other.dispose();
  }
});

Deno.test("the function never reads the raw material file", async () => {
  const source = await Deno.readTextFile(
    new URL("../../supabase/functions/generate-content/handler.ts", import.meta.url),
  );
  // It may touch generated_content and the pack tables, but never Storage and
  // never the materials table — the Knowledge Pack is the student's source.
  assert(!source.includes('storage'), "generate-content must not read Storage");
  assert(
    !source.includes('.from("materials")'),
    "generate-content must not read the materials table",
  );
});

Deno.test({
  name: "flashcards come from the Knowledge Pack, not the raw file",
  ignore: Deno.env.get("RUN_MODEL_TESTS") !== "1",
  fn: async () => {
    const school = await createTestSchool("gc-cards");
    try {
      const { chapterId } = await seedChapter(school);
      const { data: { session } } = await school.student.client.auth.getSession();
      const result = await call(session!.access_token, {
        kind: "flashcards", chapterId, studentId: school.studentRowId,
      });
      assertEquals(result.status, 200);

      const cards = result.body.payload.cards as Record<string, unknown>[];
      assert(cards.length >= 15 && cards.length <= 30, `deck size ${cards.length}`);

      const db = admin();
      const { data: skills } = await db.from("micro_skills")
        .select("id").eq("chapter_id", chapterId);
      const allowed = new Set((skills ?? []).map((s) => s.id));
      assert(
        cards.every((c) => allowed.has(c.microSkillId)),
        "every card must cite a micro-skill of its chapter",
      );
      assert(cards.every((c) => typeof c.concept === "string" && c.concept.length > 0));

      const { data: stored } = await db.from("generated_content")
        .select("kind").eq("chapter_id", chapterId).eq("kind", "flashcards");
      assert((stored ?? []).length === 1, "deck must be persisted before responding");
    } finally {
      await school.dispose();
    }
  },
});

Deno.test({
  name: "a story names the concepts it teaches and honours prep vs revise",
  ignore: Deno.env.get("RUN_MODEL_TESTS") !== "1",
  fn: async () => {
    const school = await createTestSchool("gc-story");
    try {
      const { chapterId } = await seedChapter(school);
      const { data: { session } } = await school.student.client.auth.getSession();
      const result = await call(session!.access_token, {
        kind: "story", chapterId, studentId: school.studentRowId, mode: "prep",
      });
      assertEquals(result.status, 200);
      const payload = result.body.payload;
      assert(Array.isArray(payload.scenes) && payload.scenes.length >= 4);
      assert(Array.isArray(payload.concepts) && payload.concepts.length > 0);
      assertEquals(payload.mode, "prep");
    } finally {
      await school.dispose();
    }
  },
});
