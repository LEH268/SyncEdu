import { assert, assertEquals } from "@std/assert";
import { handler } from "../../supabase/functions/suggest-teaching/handler.ts";
import { admin, anonKey, createTestSchool, supabaseUrl } from "./harness.ts";
import { createClient } from "@supabase/supabase-js";

type School = Awaited<ReturnType<typeof createTestSchool>>;

async function call(token: string | null, body: unknown) {
  const headers: Record<string, string> = { "content-type": "application/json" };
  if (token) headers.Authorization = `Bearer ${token}`;
  const response = await handler(
    new Request("http://local/suggest-teaching", {
      method: "POST",
      headers,
      body: JSON.stringify(body),
    }),
  );
  return { status: response.status, body: await response.json().catch(() => ({})) };
}

async function tokenFor(user: School["teacher"]): Promise<string> {
  const { data: { session } } = await user.client.auth.getSession();
  return session!.access_token;
}

/// A class the school's teacher takes, and one ingested chapter with a
/// Knowledge Pack, micro-skills and an explanation -- everything the handler
/// grounds the deck on.
async function seed(school: School) {
  const db = admin();
  const subjectId = crypto.randomUUID();
  const chapterId = crypto.randomUUID();
  const classId = crypto.randomUUID();
  const materialId = crypto.randomUUID();
  const skillIds = [crypto.randomUUID(), crypto.randomUUID()];

  await db.from("subjects").insert({
    id: subjectId, school_id: school.id, name: "Mathematics", chapter_count: 1,
  });
  await db.from("chapters").insert({
    id: chapterId, school_id: school.id, subject_id: subjectId, ordinal: 1,
    title: "Quadratic Equations",
  });
  await db.from("classes").insert({
    id: classId, school_id: school.id, name: "4 Cendekia", year_level: 4,
  });
  await db.from("class_subjects").insert({
    id: crypto.randomUUID(), school_id: school.id, class_id: classId,
    subject_id: subjectId, teacher_id: school.teacher.id,
  });
  await db.from("materials").insert({
    id: materialId, school_id: school.id, chapter_id: chapterId,
    uploaded_by: school.teacher.id, storage_path: `${school.id}/seed.pdf`,
    mime_type: "application/pdf", original_filename: "seed.pdf",
    ingestion_status: "ready",
  });
  await db.from("knowledge_packs").insert({
    id: crypto.randomUUID(), school_id: school.id, chapter_id: chapterId,
    material_id: materialId, model_version: "seed",
    concepts: [{ name: "Factorising", summary: "Write a quadratic as a product of two brackets." }],
    definitions: [{ term: "Root", meaning: "A value of x making the expression zero." }],
    formulas: [{ name: "Quadratic formula", expression: "x = (-b +/- sqrt(b^2-4ac)) / 2a" }],
    worked_examples: [{ problem: "x^2 - 5x + 6 = 0", solution: "(x-2)(x-3) = 0, so x = 2 or 3." }],
  });
  await db.from("micro_skills").insert([
    { id: skillIds[0], school_id: school.id, chapter_id: chapterId, slug: "factorising", label: "Factorising a quadratic", description: "Split into two brackets", ordinal: 1 },
    { id: skillIds[1], school_id: school.id, chapter_id: chapterId, slug: "discriminant", label: "Using the discriminant", description: "Decide how many roots exist", ordinal: 2 },
  ]);
  await db.from("micro_skill_explanations").insert({
    id: crypto.randomUUID(), school_id: school.id, micro_skill_id: skillIds[0],
    body: "Find two numbers multiplying to c and adding to b.",
  });

  return { chapterId, classId, skillIds, subjectId };
}

function validBody(
  seeded: Awaited<ReturnType<typeof seed>>,
  overrides: Record<string, unknown> = {},
) {
  return {
    insightId: crypto.randomUUID(),
    classId: seeded.classId,
    chapterId: seeded.chapterId,
    className: "4 Cendekia",
    ruleHeadline:
      "1 of 1 flagged micro-skill in Quadratic Equations also failed in your other classes.",
    signals: [
      {
        microSkillId: seeded.skillIds[0],
        sentence:
          "60% of the assessed class (6 of 10, out of 12 enrolled) is struggling with Factorising a quadratic.",
        scope: "materialWide",
        misconceptions: [
          {
            questionStem: "Solve x^2 - 5x + 6 = 0",
            optionText: "x = -2 or -3",
            studentCount: 6,
          },
        ],
      },
    ],
    ...overrides,
  };
}

Deno.test("only a teacher's token reaches the review", async () => {
  const school = await createTestSchool("ti-auth");
  try {
    const seeded = await seed(school);

    assertEquals((await call(null, validBody(seeded))).status, 401);
    assertEquals(
      (await call(await tokenFor(school.student), validBody(seeded))).status,
      403,
    );
    // An admin is refused too. This is a teacher's own diagnostic, and an
    // admin-reachable version of it is the appraisal tool the design
    // deliberately does not build.
    assertEquals(
      (await call(await tokenFor(school.admin), validBody(seeded))).status,
      403,
    );
  } finally {
    await school.dispose();
  }
});

Deno.test("a teacher who does not take the class is refused", async () => {
  const school = await createTestSchool("ti-notmine");
  try {
    const seeded = await seed(school);
    const db = admin();
    // Hand the class to somebody else.
    await db.from("class_subjects").update({ teacher_id: school.admin.id })
      .eq("class_id", seeded.classId);

    const result = await call(await tokenFor(school.teacher), validBody(seeded));
    assertEquals(result.status, 403);
  } finally {
    await school.dispose();
  }
});

Deno.test("malformed input is refused before any model call", async () => {
  const school = await createTestSchool("ti-malformed");
  try {
    const seeded = await seed(school);
    const token = await tokenFor(school.teacher);

    // A 400 is itself the proof that no model call happened: validateBody runs
    // before GeminiClient.fromEnvironment(), so a request that reached Gemini
    // could only come back 200 or 5xx. Deliberately NOT asserted by requiring
    // GEMINI_API_KEY_* to be unset -- an assertion about the developer's .env
    // fails on any machine configured to run the model tier, which is exactly
    // what happens to summarise_class_test.ts in this environment.
    const before = await admin()
      .from("teaching_insights").select("id").eq("class_id", seeded.classId);

    assertEquals(
      (await call(token, validBody(seeded, { insightId: "not-a-uuid" }))).status,
      400,
    );
    assertEquals(
      (await call(token, validBody(seeded, { className: "" }))).status,
      400,
    );
    // No finding means nothing to write about: prose here would be invention.
    assertEquals(
      (await call(token, validBody(seeded, { signals: [] }))).status,
      400,
    );
    assertEquals(
      (await call(
        token,
        validBody(seeded, {
          signals: [{ microSkillId: seeded.skillIds[0], sentence: "x", scope: "made-up", misconceptions: [] }],
        }),
      )).status,
      400,
    );

    const notJson = await handler(
      new Request("http://local/suggest-teaching", {
        method: "POST",
        headers: { "Authorization": `Bearer ${token}`, "content-type": "application/json" },
        body: "not json",
      }),
    );
    assertEquals(notJson.status, 400);

    // Nothing was generated, so nothing was persisted either.
    const after = await admin()
      .from("teaching_insights").select("id").eq("class_id", seeded.classId);
    assertEquals(after.data?.length ?? 0, before.data?.length ?? 0);
  } finally {
    await school.dispose();
  }
});

Deno.test("a signal citing another chapter's skill is refused, not passed through", async () => {
  const school = await createTestSchool("ti-crosschapter");
  try {
    const seeded = await seed(school);
    const token = await tokenFor(school.teacher);

    // A well-formed uuid that is not a micro-skill of this chapter.
    const result = await call(
      token,
      validBody(seeded, {
        signals: [
          {
            microSkillId: crypto.randomUUID(),
            sentence: "60% struggling",
            scope: "materialWide",
            misconceptions: [],
          },
        ],
      }),
    );
    assertEquals(result.status, 400);
    assertEquals(result.body.error, "no_signal_matches_chapter");
  } finally {
    await school.dispose();
  }
});

Deno.test("a chapter with no Knowledge Pack cannot be reviewed", async () => {
  const school = await createTestSchool("ti-noingest");
  try {
    const seeded = await seed(school);
    await admin().from("knowledge_packs").delete().eq("chapter_id", seeded.chapterId);

    const result = await call(await tokenFor(school.teacher), validBody(seeded));
    assertEquals(result.status, 409);
    assertEquals(result.body.error, "chapter_not_ingested");
  } finally {
    await school.dispose();
  }
});

Deno.test("a review is readable by its author and by nobody else", async () => {
  const school = await createTestSchool("ti-rls");
  try {
    const seeded = await seed(school);
    const db = admin();

    // A second teacher in the SAME school, who also takes the same class.
    const email = `teacher-rls-${crypto.randomUUID()}@test.syncedu.invalid`;
    const { data: created } = await db.auth.admin.createUser({
      email, password: "seam-Test-Password-1!", email_confirm: true,
    });
    await db.from("profiles").insert({
      id: created!.user!.id, school_id: school.id, role: "teacher",
      full_name: "Seam teacher two", email,
    });
    await db.from("class_subjects").insert({
      id: crypto.randomUUID(), school_id: school.id, class_id: seeded.classId,
      subject_id: seeded.subjectId, teacher_id: created!.user!.id,
    });
    const other = createClient(supabaseUrl(), anonKey(), {
      auth: { persistSession: false, autoRefreshToken: false },
    });
    await other.auth.signInWithPassword({ email, password: "seam-Test-Password-1!" });

    const insightId = crypto.randomUUID();
    await db.from("teaching_insights").insert({
      id: insightId, school_id: school.id, teacher_id: school.teacher.id,
      class_id: seeded.classId, chapter_id: seeded.chapterId,
      signals: [], summary: "seeded", actions: [], deck: {}, source: "rule",
    });

    // The author reads it through RLS, not through the service role.
    const { data: mine } = await school.teacher.client
      .from("teaching_insights").select("id, summary").eq("id", insightId);
    assertEquals(mine?.length, 1);
    assertEquals(mine![0].summary, "seeded");

    // A colleague who teaches the very same class still cannot.
    const { data: theirs } = await other
      .from("teaching_insights").select("id").eq("id", insightId);
    assertEquals(theirs?.length ?? 0, 0);

    // Nor can an admin of the school.
    const { data: asAdmin } = await school.admin.client
      .from("teaching_insights").select("id").eq("id", insightId);
    assertEquals(asAdmin?.length ?? 0, 0);

    // And a teacher cannot file a review under someone else's name.
    const { error: forged } = await other.from("teaching_insights").insert({
      id: crypto.randomUUID(), school_id: school.id,
      teacher_id: school.teacher.id, class_id: seeded.classId,
      chapter_id: seeded.chapterId,
    });
    assert(forged, "RLS must refuse an insert naming another teacher");

    await db.auth.admin.deleteUser(created!.user!.id).catch(() => {});
  } finally {
    await school.dispose();
  }
});

Deno.test({
  name: "the deck cites only the flagged skill and persists before responding",
  ignore: Deno.env.get("RUN_MODEL_TESTS") !== "1",
  async fn() {
    const school = await createTestSchool("ti-model");
    try {
      const seeded = await seed(school);
      const body = validBody(seeded);
      const result = await call(await tokenFor(school.teacher), body);

      assertEquals(result.status, 200);
      assertEquals(result.body.source, "ai");
      assertEquals(result.body.id, body.insightId);

      // Structural only: the prose itself is never asserted on.
      assert(typeof result.body.summary === "string" && result.body.summary.length > 0);
      assert(Array.isArray(result.body.deck.slides));
      assert(result.body.deck.slides.length >= 4, "a re-teach deck needs slides");

      // The deck covers what did not land and nothing else: the unflagged
      // second micro-skill must not appear.
      const cited = new Set<string>([
        ...result.body.deck.slides.map((s: { microSkillId: string }) => s.microSkillId),
        ...result.body.actions.map((a: { microSkillId: string }) => a.microSkillId),
      ]);
      assertEquals(cited.size, 1);
      assert(cited.has(seeded.skillIds[0]));
      assert(!cited.has(seeded.skillIds[1]));

      // Persisted inside the call, before responding.
      const { data: row } = await admin()
        .from("teaching_insights").select("*").eq("id", body.insightId).single();
      assert(row, "the review must be persisted before the response returns");
      assertEquals(row.source, "ai");
      assertEquals(row.teacher_id, school.teacher.id);
      // The figures it fired on are stored verbatim beside the prose.
      assertEquals(row.signals.length, 1);
      assertEquals(row.signals[0].microSkillId, seeded.skillIds[0]);
    } finally {
      await school.dispose();
    }
  },
});
