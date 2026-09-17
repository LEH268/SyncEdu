import { assert, assertEquals, assertNotEquals } from "@std/assert";
import { createClient } from "@supabase/supabase-js";
import { admin, anonKey, supabaseUrl } from "./harness.ts";

Deno.test("schools accepts a client-supplied id and applies defaults", async () => {
  const db = admin();
  const id = crypto.randomUUID();

  const { error } = await db.from("schools").insert({
    id,
    name: "Tenancy Probe",
    education_level: "secondary",
  });
  assertEquals(error, null);

  const { data } = await db.from("schools").select("*").eq("id", id).single();
  assertEquals(data!.id, id, "the client-supplied id must be preserved");
  assertEquals(data!.content_language, "en");
  assertEquals(data!.max_offline_days, 30);
  assertEquals(data!.deleted_at, null);

  await db.from("schools").delete().eq("id", id);
});

Deno.test("updated_at advances on update while created_at holds", async () => {
  const db = admin();
  const id = crypto.randomUUID();
  await db.from("schools").insert({
    id,
    name: "Trigger Probe",
    education_level: "secondary",
  });

  const { data: before } = await db
    .from("schools").select("created_at, updated_at").eq("id", id).single();

  await new Promise((resolve) => setTimeout(resolve, 1100));
  await db.from("schools").update({ name: "Trigger Probe 2" }).eq("id", id);

  const { data: after } = await db
    .from("schools").select("created_at, updated_at").eq("id", id).single();

  assertEquals(after!.created_at, before!.created_at);
  assertNotEquals(after!.updated_at, before!.updated_at);
  assert(
    new Date(after!.updated_at) > new Date(before!.updated_at),
    "the set_updated_at trigger must move updated_at forward",
  );

  await db.from("schools").delete().eq("id", id);
});

Deno.test("education_level rejects a value outside the vocabulary", async () => {
  const db = admin();
  const { error } = await db.from("schools").insert({
    id: crypto.randomUUID(),
    name: "Bad Level",
    education_level: "kindergarten",
  });
  assert(error !== null, "the CHECK constraint must reject 'kindergarten'");
});

Deno.test("profiles.role rejects a value outside the vocabulary", async () => {
  const db = admin();
  const schoolId = crypto.randomUUID();
  await db.from("schools").insert({
    id: schoolId,
    name: "Role Probe",
    education_level: "secondary",
  });

  const { error } = await db.from("profiles").insert({
    id: crypto.randomUUID(),
    school_id: schoolId,
    role: "principal",
    full_name: "Nobody",
    email: "nobody@test.syncedu.invalid",
  });
  assert(error !== null, "the CHECK constraint must reject 'principal'");

  await db.from("schools").delete().eq("id", schoolId);
});

Deno.test("self-registration via the anon key is refused", async () => {
  const client = createClient(supabaseUrl(), anonKey(), {
    auth: { persistSession: false },
  });
  const { error } = await client.auth.signUp({
    email: `self-reg-${crypto.randomUUID()}@test.syncedu.invalid`,
    password: "SomePassword123!",
  });
  assert(error !== null, "self-registration must be refused when enable_signup is false");
});
