import { assert, assertEquals, assertNotEquals } from "@std/assert";
import { admin, createTestSchool } from "./harness.ts";

Deno.test("createTestSchool provisions three signed-in users", async () => {
  const school = await createTestSchool("fixture");
  try {
    assertNotEquals(school.id, "");
    for (const user of [school.admin, school.teacher, school.student]) {
      assert(user.email.endsWith("@test.syncedu.invalid"));
      const { data } = await user.client.auth.getSession();
      assert(data.session !== null, `${user.email} should be signed in`);
    }

    const { data: profiles } = await admin()
      .from("profiles").select("role").eq("school_id", school.id);
    assertEquals(profiles!.length, 3);
    assertEquals(
      profiles!.map((p) => p.role).sort(),
      ["admin", "student", "teacher"],
    );

    const { data: students } = await admin()
      .from("students").select("id").eq("school_id", school.id);
    assertEquals(students!.length, 1);
    assertEquals(students![0].id, school.studentRowId);
  } finally {
    await school.dispose();
  }
});

Deno.test("dispose removes the school, its profiles and its auth users", async () => {
  const school = await createTestSchool("teardown");
  const studentUserId = school.student.id;
  await school.dispose();

  const db = admin();

  const { data: schools } = await db.from("schools").select("id").eq("id", school.id);
  assertEquals(schools!.length, 0);

  const { data: profiles } = await db.from("profiles").select("id").eq("school_id", school.id);
  assertEquals(profiles!.length, 0);

  const { data: user, error } = await db.auth.admin.getUserById(studentUserId);
  assert(error !== null || user?.user === null, "the auth user must be gone");
});

Deno.test("two schools created concurrently do not see each other", async () => {
  const [a, b] = await Promise.all([
    createTestSchool("iso-a"),
    createTestSchool("iso-b"),
  ]);
  try {
    assertNotEquals(a.id, b.id);
    const { data } = await admin()
      .from("profiles").select("id").eq("school_id", a.id);
    assertEquals(data!.length, 3, "school A must hold exactly its own three profiles");
  } finally {
    await Promise.all([a.dispose(), b.dispose()]);
  }
});
