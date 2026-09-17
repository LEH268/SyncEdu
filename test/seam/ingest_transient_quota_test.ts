import { assert, assertEquals } from "@std/assert";
import {
  handler,
  isTransientQuotaError,
} from "../../supabase/functions/ingest-material/handler.ts";
import { admin, createTestSchool } from "./harness.ts";

// The exact messages GeminiClient throws when capacity is exhausted.
const ROTATION_EXHAUSTED =
  "Gemini key rotation exhausted: every configured key failed (rate limit or network error)";

Deno.test("isTransientQuotaError classifies Gemini exhaustion, not real failures", () => {
  assert(isTransientQuotaError(ROTATION_EXHAUSTED));
  assert(isTransientQuotaError("every configured key was rate limited"));
  assert(isTransientQuotaError("rotation exhausted"));
  assert(!isTransientQuotaError("knowledge pack insert failed: duplicate key"));
  assert(!isTransientQuotaError("expected 5-8 micro-skills, model returned 2"));
  assert(!isTransientQuotaError("Gemini rejected the request (400): bad schema"));
});

Deno.test("a 429 storm leaves the material resumable, not failed", async () => {
  const school = await createTestSchool("ingest-quota");
  const db = admin();
  const subjectId = crypto.randomUUID();
  const chapterId = crypto.randomUUID();
  const materialId = crypto.randomUUID();
  const path = `${school.id}/${materialId}.pdf`;

  await db.from("subjects").insert({
    id: subjectId, school_id: school.id, name: "Mathematics", chapter_count: 1,
  });
  await db.from("chapters").insert({
    id: chapterId, school_id: school.id, subject_id: subjectId,
    ordinal: 1, title: "Quadratic Equations",
  });
  await db.storage.from("materials").upload(
    path,
    new Blob([new TextEncoder().encode("%PDF-1.4\n")], { type: "application/pdf" }),
    { contentType: "application/pdf" },
  );
  await db.from("materials").insert({
    id: materialId, school_id: school.id, chapter_id: chapterId,
    uploaded_by: school.teacher.id, storage_path: path,
    mime_type: "application/pdf", original_filename: "ch1.pdf",
  });

  const { data: session } = await school.teacher.client.auth.getSession();
  const token = session.session!.access_token;

  // Force GeminiClient down its rotation-exhausted path: every key 429s.
  const realFetch = globalThis.fetch;
  globalThis.fetch = ((input: string | URL | Request, init?: RequestInit) => {
    const url = typeof input === "string" ? input : input.toString();
    if (url.includes("generativelanguage.googleapis.com")) {
      return Promise.resolve(new Response("rate limited", { status: 429 }));
    }
    return realFetch(input as Request, init);
  }) as typeof fetch;

  try {
    const response = await handler(
      new Request("http://local/ingest-material", {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${token}`,
          "content-type": "application/json",
        },
        body: JSON.stringify({ materialId }),
      }),
    );
    await response.body?.cancel();
    assertEquals(
      response.status,
      500,
      "the Gemini exhaustion still surfaces as a failure to the caller",
    );

    const { data: after } = await admin()
      .from("materials")
      .select("attempts, ingestion_status, ingestion_error")
      .eq("id", materialId)
      .single();

    assertEquals(after!.attempts, 0, "transient quota must not consume retry budget");
    assertEquals(
      after!.ingestion_status,
      "pending",
      "transient quota must never mark a material failed",
    );
    assert(
      (after!.ingestion_error ?? "").length > 0,
      "the error is still recorded for observability",
    );
  } finally {
    globalThis.fetch = realFetch;
    await admin().storage.from("materials").remove([path]);
    await school.dispose();
  }
});
