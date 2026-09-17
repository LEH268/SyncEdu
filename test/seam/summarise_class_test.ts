import { assert, assertEquals } from "@std/assert";
import { handler } from "../../supabase/functions/summarise-class/handler.ts";
import { createTestSchool } from "./harness.ts";

async function call(token: string, body: unknown) {
  const response = await handler(
    new Request("http://local/summarise-class", {
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

const VALID_BODY = {
  className: "4 Cendekia",
  heatmap: [
    { chapterId: "c1", chapterTitle: "Quadratic Equations", accuracy: 0.4, band: "red" },
  ],
  mostMissed: [
    { microSkillId: "s1", microSkillLabel: "Completing the square", errorRate: 0.8, total: 12 },
  ],
  atRisk: [
    { name: "Ali", reasons: ["3 low scores in a row"] },
  ],
};

// Handed figures, it returns prose about exactly those figures -- proven
// structurally rather than by mocking the database, since a black-box
// behavioural test would have nothing to assert on: there is no table this
// handler could have queried in the first place. The static check that
// follows is the actual proof; this test documents *why* that's sufficient.
Deno.test("the function never queries the database", async () => {
  const source = await Deno.readTextFile(
    new URL("../../supabase/functions/summarise-class/handler.ts", import.meta.url),
  );
  assert(
    !source.includes(".from("),
    "summarise-class must never call .from(): every figure it describes is handed to it, never queried",
  );
});

Deno.test("a teacher's token is required", async () => {
  const school = await createTestSchool("sc-auth");
  try {
    // No token at all.
    const noAuth = await handler(
      new Request("http://local/summarise-class", {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify(VALID_BODY),
      }),
    );
    assertEquals(noAuth.status, 401);

    // A student's token: wrong role.
    const { data: { session: studentSession } } = await school.student.client.auth.getSession();
    const asStudent = await call(studentSession!.access_token, VALID_BODY);
    assertEquals(asStudent.status, 403);

    // An admin's token: also wrong role for this endpoint (teacher-only).
    const { data: { session: adminSession } } = await school.admin.client.auth.getSession();
    const asAdmin = await call(adminSession!.access_token, VALID_BODY);
    assertEquals(asAdmin.status, 403);
  } finally {
    await school.dispose();
  }
});

Deno.test("malformed input is refused with 400 rather than summarised", async () => {
  const school = await createTestSchool("sc-malformed");
  try {
    const { data: { session } } = await school.teacher.client.auth.getSession();
    const token = session!.access_token;

    // Ensure no Gemini keys are configured for this process so that, if the
    // handler incorrectly reached GeminiClient.fromEnvironment() despite the
    // malformed body, the test would fail loudly with an unhandled 500
    // rather than silently pass. (This assumes the seam runner's env does
    // not set GEMINI_API_KEY_*, which holds in this environment.)
    for (const n of [1, 2, 3]) {
      assertEquals(
        Deno.env.get(`GEMINI_API_KEY_${n}`),
        undefined,
        "this test relies on no Gemini key being configured to prove Gemini was never reached",
      );
    }

    const missingClassName = await call(token, { ...VALID_BODY, className: undefined });
    assertEquals(missingClassName.status, 400);

    const wrongHeatmapType = await call(token, { ...VALID_BODY, heatmap: "not-an-array" });
    assertEquals(wrongHeatmapType.status, 400);

    const wrongAtRiskShape = await call(token, {
      ...VALID_BODY,
      atRisk: [{ name: "Ali" }], // missing reasons
    });
    assertEquals(wrongAtRiskShape.status, 400);

    const notJson = await handler(
      new Request("http://local/summarise-class", {
        method: "POST",
        headers: { "Authorization": `Bearer ${token}`, "content-type": "application/json" },
        body: "not json",
      }),
    );
    assertEquals(notJson.status, 400);
  } finally {
    await school.dispose();
  }
});

Deno.test({
  name: "the summary names the weakest concept it was given",
  ignore: Deno.env.get("RUN_MODEL_TESTS") !== "1",
  fn: async () => {
    const school = await createTestSchool("sc-model");
    try {
      const { data: { session } } = await school.teacher.client.auth.getSession();
      const result = await call(session!.access_token, VALID_BODY);

      assertEquals(result.status, 200);
      assert(
        typeof result.body.summary === "string" && result.body.summary.length > 0,
        "expected a non-empty summary",
      );
      assert(
        result.body.summary.includes("Completing the square"),
        `expected the weakest concept's label to appear in the summary, got: ${result.body.summary}`,
      );
    } finally {
      await school.dispose();
    }
  },
});
