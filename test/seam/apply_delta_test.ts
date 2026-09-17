import { assert, assertEquals } from "@std/assert";
import { admin, createTestSchool } from "./harness.ts";

Deno.test("tier 3: a matching precondition applies the write", async () => {
  const school = await createTestSchool("t3-ok");
  try {
    const { data, error } = await school.admin.client.rpc("apply_delta", {
      p_table: "students",
      p_row_id: school.studentRowId,
      p_field: "special_needs",
      p_observed: [],
      p_new: ["Dyslexia"],
      p_client_ts: new Date().toISOString(),
    });

    assertEquals(error, null);
    assertEquals(data.status, "applied");

    const { data: row } = await school.admin.client
      .from("students").select("special_needs, version")
      .eq("id", school.studentRowId).single();
    assertEquals(row!.special_needs, ["Dyslexia"]);
    assertEquals(row!.version, 2, "an applied delta must bump version");
  } finally {
    await school.dispose();
  }
});

Deno.test("tier 3: a stale precondition is refused and logged", async () => {
  const school = await createTestSchool("t3-conflict");
  try {
    // Someone else already moved the value while this device was offline.
    await admin().from("students")
      .update({ special_needs: ["ADHD"] }).eq("id", school.studentRowId);

    const { data } = await school.admin.client.rpc("apply_delta", {
      p_table: "students",
      p_row_id: school.studentRowId,
      p_field: "special_needs",
      p_observed: [],
      p_new: ["Dyslexia"],
      p_client_ts: new Date().toISOString(),
    });

    assertEquals(data.status, "conflict");
    assertEquals(data.server_value, ["ADHD"]);

    const { data: row } = await school.admin.client
      .from("students").select("special_needs")
      .eq("id", school.studentRowId).single();
    assertEquals(row!.special_needs, ["ADHD"], "the stale write must not land");

    const { data: conflicts } = await admin()
      .from("sync_conflicts").select("*").eq("row_id", school.studentRowId);
    assertEquals(conflicts!.length, 1);
    assertEquals(conflicts![0].field, "special_needs");
  } finally {
    await school.dispose();
  }
});

Deno.test("a field absent from the whitelist is refused", async () => {
  const school = await createTestSchool("not-writable");
  try {
    const { data } = await school.admin.client.rpc("apply_delta", {
      p_table: "students",
      p_row_id: school.studentRowId,
      p_field: "school_id",
      p_observed: school.id,
      p_new: crypto.randomUUID(),
      p_client_ts: new Date().toISOString(),
    });
    assertEquals(data.status, "forbidden");
  } finally {
    await school.dispose();
  }
});

Deno.test("a row the caller cannot see reports not_visible, not a value", async () => {
  const [a, b] = await Promise.all([
    createTestSchool("vis-a"),
    createTestSchool("vis-b"),
  ]);
  try {
    const { data } = await a.admin.client.rpc("apply_delta", {
      p_table: "students",
      p_row_id: b.studentRowId,
      p_field: "special_needs",
      p_observed: [],
      p_new: ["ASD"],
      p_client_ts: new Date().toISOString(),
    });

    // Reporting the server value here would leak another school's data
    // through a function that reads under RLS.
    assertEquals(data.status, "not_visible");
    assertEquals(data.server_value ?? null, null);
  } finally {
    await Promise.all([a.dispose(), b.dispose()]);
  }
});

Deno.test("a table name with quotes cannot escape the identifier quoting", async () => {
  const school = await createTestSchool("injection");
  try {
    const { data, error } = await school.admin.client.rpc("apply_delta", {
      p_table: 'students"; drop table public.students; --',
      p_row_id: school.studentRowId,
      p_field: "special_needs",
      p_observed: [],
      p_new: ["x"],
      p_client_ts: new Date().toISOString(),
    });

    // The whitelist rejects it before any SQL is composed.
    assertEquals(error, null);
    assertEquals(data.status, "forbidden");

    const { data: stillThere } = await admin().from("students").select("id").limit(1);
    assert(Array.isArray(stillThere), "public.students must still exist");
  } finally {
    await school.dispose();
  }
});
