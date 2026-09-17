import { assert, assertEquals } from "@std/assert";
import { handler } from "../../supabase/functions/ingest-material/handler.ts";
import { admin, createTestSchool } from "./harness.ts";

/// The cron sweep calls ingest-material with the project's service-role JWT,
/// which resolves to no profile row. The handler must recognise that token by
/// its `role: service_role` claim and take the sweep path rather than 401/403.
/// (Regression: an earlier version compared the bearer to the literal key
/// string, which does not match what the deployed runtime injects.)

async function call(token: string, materialId: string) {
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
  return { status: response.status, body: await response.json() };
}

Deno.test("the service-role JWT is accepted as the sweep, not rejected as auth", async () => {
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const school = await createTestSchool("sweep-auth");
  const db = admin();

  const subjectId = crypto.randomUUID();
  const chapterId = crypto.randomUUID();
  const materialId = crypto.randomUUID();
  const path = `${school.id}/${materialId}.pdf`;

  try {
    await db.from("subjects").insert({
      id: subjectId, school_id: school.id, name: "Mathematics", chapter_count: 1,
    });
    await db.from("chapters").insert({
      id: chapterId, school_id: school.id, subject_id: subjectId,
      ordinal: 1, title: "Quadratic Equations",
    });
    await db.storage.from("materials").upload(
      path,
      new Blob([new TextEncoder().encode("%PDF-1.4\n%%EOF") as unknown as BlobPart], {
        type: "application/pdf",
      }),
      { contentType: "application/pdf" },
    );
    await db.from("materials").insert({
      id: materialId, school_id: school.id, chapter_id: chapterId,
      uploaded_by: school.teacher.id, storage_path: path,
      mime_type: "application/pdf", original_filename: "ch1.pdf",
      // A terminal status keeps the handler in its no-op branch, so this test
      // exercises the auth decision without invoking the model.
      ingestion_status: "ready",
    });

    const result = await call(serviceKey, materialId);
    assert(
      result.status !== 401 && result.status !== 403,
      `sweep token must not be an auth failure, got ${result.status}: ${
        JSON.stringify(result.body)
      }`,
    );
    assertEquals(result.status, 200);
    assertEquals(result.body.status, "ready");
  } finally {
    await db.storage.from("materials").remove([path]);
    await school.dispose();
  }
});
