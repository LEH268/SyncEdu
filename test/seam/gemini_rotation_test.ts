import { assert, assertEquals } from "@std/assert";
import { GeminiClient } from "../../supabase/functions/_shared/gemini.ts";

function response(status: number, body: unknown): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "content-type": "application/json" },
  });
}

function okBody(text: string) {
  return { candidates: [{ content: { parts: [{ text }] } }] };
}

Deno.test("a successful call uses one key and parses the JSON payload", async () => {
  const used: string[] = [];
  const client = new GeminiClient(["k1", "k2", "k3"], (url) => {
    used.push(new URL(url).searchParams.get("key")!);
    return Promise.resolve(response(200, okBody('{"ok":true}')));
  }, 0);

  const result = await client.generateJson<{ ok: boolean }>({
    prompt: "hi",
    schema: { type: "OBJECT", properties: { ok: { type: "BOOLEAN" } } },
  });

  assertEquals(result.ok, true);
  assertEquals(used.length, 1);
});

Deno.test("a 429 advances to the next key", async () => {
  const used: string[] = [];
  const client = new GeminiClient(["k1", "k2", "k3"], (url) => {
    const key = new URL(url).searchParams.get("key")!;
    used.push(key);
    if (key === "k1") return Promise.resolve(response(429, { error: "quota" }));
    return Promise.resolve(response(200, okBody('{"ok":true}')));
  }, 0);

  await client.generateJson({ prompt: "hi", schema: { type: "OBJECT" } });

  assertEquals(used, ["k1", "k2"]);
});

Deno.test("a 503 also advances", async () => {
  const used: string[] = [];
  const client = new GeminiClient(["k1", "k2"], (url) => {
    const key = new URL(url).searchParams.get("key")!;
    used.push(key);
    if (key === "k1") return Promise.resolve(response(503, { error: "unavailable" }));
    return Promise.resolve(response(200, okBody('{"ok":true}')));
  }, 0);

  await client.generateJson({ prompt: "hi", schema: { type: "OBJECT" } });
  assertEquals(used, ["k1", "k2"]);
});

Deno.test("exhausting every key throws without disclosing a key", async () => {
  const client = new GeminiClient(["secret-one", "secret-two"], () =>
    Promise.resolve(response(429, { error: "quota" })), 0);

  let message = "";
  try {
    await client.generateJson({ prompt: "hi", schema: { type: "OBJECT" } });
    throw new Error("should have thrown");
  } catch (error) {
    message = (error as Error).message;
  }

  assert(message.includes("exhausted"), `unexpected message: ${message}`);
  assert(!message.includes("secret-one"), "a key must never appear in an error");
  assert(!message.includes("secret-two"), "a key must never appear in an error");
});

Deno.test("a thrown network error rotates to the next key without leaking it", async () => {
  const used: string[] = [];
  const client = new GeminiClient(["secret-one", "secret-two"], (url) => {
    const key = new URL(url).searchParams.get("key")!;
    used.push(key);
    if (key === "secret-one") {
      return Promise.reject(
        new TypeError(`error sending request for url (${url})`),
      );
    }
    return Promise.resolve(response(200, okBody('{"ok":true}')));
  }, 0);

  let thrownMessage = "";
  try {
    const result = await client.generateJson<{ ok: boolean }>({
      prompt: "hi",
      schema: { type: "OBJECT" },
    });
    assertEquals(result.ok, true);
  } catch (error) {
    thrownMessage = (error as Error).message;
  }

  assertEquals(used, ["secret-one", "secret-two"], "rotation must have happened");
  assert(!thrownMessage.includes("secret-one"), "no key in any thrown message");
  assert(!thrownMessage.includes("secret-two"), "no key in any thrown message");
});

Deno.test("a 400 is not retried -- a bad request fails on every key", async () => {
  let calls = 0;
  const client = new GeminiClient(["k1", "k2", "k3"], () => {
    calls++;
    return Promise.resolve(response(400, { error: { message: "bad schema" } }));
  }, 0);

  try {
    await client.generateJson({ prompt: "hi", schema: { type: "OBJECT" } });
  } catch { /* expected */ }

  assertEquals(calls, 1, "rotating on a client error just wastes quota");
});
