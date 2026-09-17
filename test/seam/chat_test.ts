import { assert, assertEquals } from "@std/assert";
import { handler } from "../../supabase/functions/chat/handler.ts";
import { kToolNames } from "../../supabase/functions/_shared/schemas.ts";
import { chatToolDeclarations } from "../../supabase/functions/_shared/schemas.ts";
import { createTestSchool } from "./harness.ts";

const CHAPTERS = [
  { ordinal: 1, title: "Quadratic Functions and Equations", taught: true },
  { ordinal: 2, title: "Number Bases", taught: true },
  { ordinal: 3, title: "Logical Reasoning", taught: false },
];

function body(utterance: string) {
  return { utterance, studentName: "Amir", chapters: CHAPTERS };
}

async function call(token: string, payload: unknown) {
  const response = await handler(
    new Request("http://local/chat", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${token}`,
        "content-type": "application/json",
      },
      body: JSON.stringify(payload),
    }),
  );
  return { status: response.status, body: await response.json() };
}

Deno.test("a student's token is required", async () => {
  const school = await createTestSchool("chat-auth");
  try {
    const noAuth = await handler(
      new Request("http://local/chat", {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify(body("quiz me on chapter 1")),
      }),
    );
    assertEquals(noAuth.status, 401);

    const { data: { session: teacherSession } } = await school.teacher.client.auth.getSession();
    const asTeacher = await call(teacherSession!.access_token, body("quiz me"));
    assertEquals(asTeacher.status, 403);
  } finally {
    await school.dispose();
  }
});

Deno.test("an empty utterance is refused with 400", async () => {
  const school = await createTestSchool("chat-empty");
  try {
    const { data: { session } } = await school.student.client.auth.getSession();
    const token = session!.access_token;

    assertEquals((await call(token, body("   "))).status, 400);
    assertEquals((await call(token, { ...body("hi"), chapters: [] })).status, 400);

    const notJson = await handler(
      new Request("http://local/chat", {
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

Deno.test("kToolNames matches the function's declarations exactly", () => {
  const declared = new Set(chatToolDeclarations([1, 2]).map((d) => d.name));
  assertEquals(declared, kToolNames);
});

Deno.test({
  name: "a quiz request returns a start_quiz tool call",
  ignore: Deno.env.get("RUN_MODEL_TESTS") !== "1",
  fn: async () => {
    const school = await createTestSchool("chat-quiz");
    try {
      const { data: { session } } = await school.student.client.auth.getSession();
      const result = await call(
        session!.access_token,
        body("quiz me on chapters 1 and 2, ten questions"),
      );
      assertEquals(result.status, 200);
      assertEquals(result.body.toolCall.name, "start_quiz");
      assertEquals(result.body.toolCall.args.chapter_ordinals, [1, 2]);
    } finally {
      await school.dispose();
    }
  },
});

Deno.test({
  name: "a conversational question returns a reply with no tool call",
  ignore: Deno.env.get("RUN_MODEL_TESTS") !== "1",
  fn: async () => {
    const school = await createTestSchool("chat-talk");
    try {
      const { data: { session } } = await school.student.client.auth.getSession();
      const result = await call(session!.access_token, body("how are you feeling today"));
      assertEquals(result.status, 200);
      assert(typeof result.body.reply === "string" && result.body.reply.length > 0);
      assertEquals(result.body.toolCall, undefined);
    } finally {
      await school.dispose();
    }
  },
});

Deno.test({
  name: "a tool call never names a chapter the student was not offered",
  ignore: Deno.env.get("RUN_MODEL_TESTS") !== "1",
  fn: async () => {
    const school = await createTestSchool("chat-oob");
    try {
      const { data: { session } } = await school.student.client.auth.getSession();
      const result = await call(session!.access_token, body("quiz me on chapter 9"));
      assertEquals(result.status, 200);
      if (result.body.toolCall?.args?.chapter_ordinals) {
        for (const n of result.body.toolCall.args.chapter_ordinals) {
          assert([1, 2, 3].includes(n), `routed to an unlisted chapter: ${n}`);
        }
      }
    } finally {
      await school.dispose();
    }
  },
});
