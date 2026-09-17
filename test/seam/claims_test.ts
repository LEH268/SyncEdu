import { assert, assertEquals } from "@std/assert";
import { createTestSchool } from "./harness.ts";

/// Decodes a JWT payload. Base64url needs re-padding before atob will take it.
function decodeJwtPayload(token: string): Record<string, unknown> {
  const parts = token.split(".");
  assertEquals(parts.length, 3, "not a JWT");
  const base64 = parts[1].replace(/-/g, "+").replace(/_/g, "/");
  const padded = base64 + "=".repeat((4 - (base64.length % 4)) % 4);
  return JSON.parse(atob(padded)) as Record<string, unknown>;
}

Deno.test("the hook injects school_id and user_role for every role", async () => {
  const school = await createTestSchool("claims");
  try {
    const cases: Array<[string, typeof school.admin]> = [
      ["admin", school.admin],
      ["teacher", school.teacher],
      ["student", school.student],
    ];

    for (const [expectedRole, user] of cases) {
      const { data } = await user.client.auth.getSession();
      const claims = decodeJwtPayload(data.session!.access_token);

      assertEquals(claims.school_id, school.id, `${expectedRole} school_id`);
      assertEquals(claims.user_role, expectedRole, `${expectedRole} user_role`);
      assertEquals(claims.sub, user.id);
    }
  } finally {
    await school.dispose();
  }
});

Deno.test("the reserved `role` claim is left untouched", async () => {
  // PostgREST switches Postgres roles based on the top-level `role` claim.
  // If the hook ever overwrites it, every authenticated request in the system
  // breaks. This test is the guard against that regression.
  const school = await createTestSchool("reserved");
  try {
    const { data } = await school.teacher.client.auth.getSession();
    const claims = decodeJwtPayload(data.session!.access_token);

    assertEquals(claims.role, "authenticated");
    assertEquals(claims.user_role, "teacher");
    assert(claims.role !== claims.user_role, "the two claims must stay distinct");
  } finally {
    await school.dispose();
  }
});
