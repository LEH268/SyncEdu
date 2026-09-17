import { assert, assertEquals } from "@std/assert";
import { admin, createTestSchool } from "./harness.ts";

Deno.test("a watermark query returns only rows changed since", async () => {
  const school = await createTestSchool("watermark");
  try {
    const { data: initial } = await school.admin.client
      .from("students").select("updated_at").eq("id", school.studentRowId).single();
    const watermark = initial!.updated_at as string;

    const { data: nothing } = await school.admin.client
      .from("students").select("id").gt("updated_at", watermark);
    assertEquals(nothing!.length, 0);

    await new Promise((resolve) => setTimeout(resolve, 1100));
    await admin().from("students")
      .update({ special_needs_note: "touched" }).eq("id", school.studentRowId);

    const { data: changed } = await school.admin.client
      .from("students").select("id").gt("updated_at", watermark);
    assertEquals(changed!.length, 1);
  } finally {
    await school.dispose();
  }
});

Deno.test("a tombstone is visible to a watermark query", async () => {
  const school = await createTestSchool("tombstone");
  try {
    const { data: before } = await school.admin.client
      .from("students").select("updated_at").eq("id", school.studentRowId).single();

    await new Promise((resolve) => setTimeout(resolve, 1100));
    await admin().from("students")
      .update({ deleted_at: new Date().toISOString() }).eq("id", school.studentRowId);

    const { data } = await school.admin.client
      .from("students").select("id, deleted_at")
      .gt("updated_at", before!.updated_at as string);

    assertEquals(data!.length, 1, "a soft delete must reach the puller");
    assert(data![0].deleted_at !== null);
  } finally {
    await school.dispose();
  }
});

Deno.test("a duplicate insert with the same id is ignored, not rejected",
  async () => {
    const school = await createTestSchool("idempotent");
    const rowId = crypto.randomUUID();
    try {
      const row = {
        id: rowId,
        school_id: school.id,
        table_name: "students",
        field: "special_needs",
        row_id: school.studentRowId,
        attempted_by: school.admin.id,
      };

      // sync_conflicts stands in for any append-only tier-1 table: the
      // property under test is the upsert header, not the table.
      const first = await admin().from("sync_conflicts")
        .upsert([row], { ignoreDuplicates: true });
      assertEquals(first.error, null);

      const second = await admin().from("sync_conflicts")
        .upsert([row], { ignoreDuplicates: true });
      assertEquals(second.error, null, "replay must not error");

      const { data } = await admin()
        .from("sync_conflicts").select("id").eq("id", rowId);
      assertEquals(data!.length, 1, "replay must not duplicate");
    } finally {
      await admin().from("sync_conflicts").delete().eq("id", rowId);
      await school.dispose();
    }
  });
