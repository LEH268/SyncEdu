import { assert, assertEquals } from "@std/assert";
import { handler } from "../../supabase/functions/provision-users/handler.ts";
import { admin, createTestSchool, type TestUser } from "./harness.ts";

async function callAs(token: string, body: unknown): Promise<Response> {
  return await handler(
    new Request("http://local/provision-users", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${token}`,
        "content-type": "application/json",
      },
      body: JSON.stringify(body),
    }),
  );
}

async function tokenFor(user: TestUser): Promise<string> {
  const { data } = await user.client.auth.getSession();
  return data.session!.access_token;
}

Deno.test("an admin can provision a teacher and a student", async () => {
  const school = await createTestSchool("provision");
  const emails = [
    `new-teacher-${crypto.randomUUID()}@test.syncedu.invalid`,
    `new-student-${crypto.randomUUID()}@test.syncedu.invalid`,
  ];
  try {
    const response = await callAs(await tokenFor(school.admin), {
      users: [
        { email: emails[0], fullName: "Cikgu Aisyah", role: "teacher" },
        { email: emails[1], fullName: "Lim Wei Jie", role: "student" },
      ],
    });

    assertEquals(response.status, 200);
    const body = await response.json();
    assertEquals(body.failed.length, 0);
    assertEquals(body.created.length, 2);

    for (const created of body.created) {
      assert(
        created.temporaryPassword.length >= 12,
        "a usable temporary password must be returned for the admin to hand out",
      );
    }

    const db = admin();
    const { data: profiles } = await db
      .from("profiles").select("role, email").eq("school_id", school.id);
    assertEquals(profiles!.length, 5, "three fixture users plus two new ones");

    // Only the student gets a students row.
    const { data: students } = await db
      .from("students").select("profile_id").eq("school_id", school.id);
    assertEquals(students!.length, 2);
  } finally {
    const db = admin();
    for (const email of emails) {
      const { data } = await db.auth.admin.listUsers({ page: 1, perPage: 200 });
      const found = data.users.find((u) => u.email === email);
      if (found) await db.auth.admin.deleteUser(found.id);
    }
    await school.dispose();
  }
});

Deno.test("a teacher's token is rejected with 403", async () => {
  const school = await createTestSchool("provision-forbidden");
  try {
    const response = await callAs(await tokenFor(school.teacher), {
      users: [{
        email: `nope-${crypto.randomUUID()}@test.syncedu.invalid`,
        fullName: "Should Not Exist",
        role: "student",
      }],
    });
    assertEquals(response.status, 403);
    assertEquals((await response.json()).error, "forbidden");
  } finally {
    await school.dispose();
  }
});

Deno.test("a missing Authorization header is rejected with 401", async () => {
  const response = await handler(
    new Request("http://local/provision-users", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ users: [] }),
    }),
  );
  assertEquals(response.status, 401);
});

Deno.test("a failed profile insert deletes the orphaned auth user", async () => {
  // 'principal' violates the profiles.role CHECK, so the auth user is created
  // and the profile insert then fails. The Admin API and the database cannot
  // share a transaction, so the function must compensate by deleting the user.
  const school = await createTestSchool("provision-rollback");
  const email = `orphan-${crypto.randomUUID()}@test.syncedu.invalid`;
  try {
    const response = await callAs(await tokenFor(school.admin), {
      users: [{ email, fullName: "Orphan Probe", role: "principal" }],
    });

    const body = await response.json();
    assertEquals(body.created.length, 0);
    assertEquals(body.failed.length, 1);
    assertEquals(body.failed[0].email, email);

    const { data } = await admin().auth.admin.listUsers({ page: 1, perPage: 200 });
    assert(
      !data.users.some((u) => u.email === email),
      "no auth user may survive a failed profile insert",
    );
  } finally {
    await school.dispose();
  }
});
