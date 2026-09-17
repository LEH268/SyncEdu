import { assert, assertEquals } from "@std/assert";
import { createTestSchool } from "./harness.ts";

Deno.test("a user reads only their own school", async () => {
  const [a, b] = await Promise.all([
    createTestSchool("rls-a"),
    createTestSchool("rls-b"),
  ]);
  try {
    const { data: visible } = await a.teacher.client.from("schools").select("id");
    assertEquals(visible!.length, 1);
    assertEquals(visible![0].id, a.id);

    const { data: crossSchool } = await a.teacher.client
      .from("schools").select("id").eq("id", b.id);
    assertEquals(crossSchool!.length, 0, "school B must be invisible to school A");
  } finally {
    await Promise.all([a.dispose(), b.dispose()]);
  }
});

Deno.test("a teacher's token cannot read another school's profiles", async () => {
  const [a, b] = await Promise.all([
    createTestSchool("prof-a"),
    createTestSchool("prof-b"),
  ]);
  try {
    const { data } = await a.teacher.client
      .from("profiles").select("id, school_id");
    assertEquals(data!.length, 3, "exactly school A's three profiles");
    assert(
      data!.every((row) => row.school_id === a.id),
      "no row from another school may appear",
    );
  } finally {
    await Promise.all([a.dispose(), b.dispose()]);
  }
});

Deno.test("a student reads only their own student row", async () => {
  const school = await createTestSchool("student-scope");
  try {
    const { data } = await school.student.client.from("students").select("id");
    assertEquals(data!.length, 1);
    assertEquals(data![0].id, school.studentRowId);
  } finally {
    await school.dispose();
  }
});

Deno.test("staff read the whole school's students", async () => {
  const school = await createTestSchool("staff-scope");
  try {
    for (const staff of [school.teacher, school.admin]) {
      const { data } = await staff.client.from("students").select("id");
      assertEquals(data!.length, 1);
      assertEquals(data![0].id, school.studentRowId);
    }
  } finally {
    await school.dispose();
  }
});

Deno.test("a student cannot update their own student row", async () => {
  const school = await createTestSchool("student-write");
  try {
    await school.student.client
      .from("students")
      .update({ special_needs: ["Dyslexia"] })
      .eq("id", school.studentRowId);

    // With no matching UPDATE policy the write affects zero rows rather than
    // erroring, so assert on the stored state rather than on the response.
    const { data } = await school.admin.client
      .from("students").select("special_needs").eq("id", school.studentRowId).single();
    assertEquals(data!.special_needs, [], "the student's write must not land");
  } finally {
    await school.dispose();
  }
});

Deno.test("an admin can update a student row in their own school", async () => {
  const school = await createTestSchool("admin-write");
  try {
    const { error } = await school.admin.client
      .from("students")
      .update({ special_needs: ["ADHD"] })
      .eq("id", school.studentRowId);
    assertEquals(error, null);

    const { data } = await school.admin.client
      .from("students").select("special_needs").eq("id", school.studentRowId).single();
    assertEquals(data!.special_needs, ["ADHD"]);
  } finally {
    await school.dispose();
  }
});

Deno.test("an admin cannot update a student in another school", async () => {
  const [a, b] = await Promise.all([
    createTestSchool("xw-a"),
    createTestSchool("xw-b"),
  ]);
  try {
    await a.admin.client
      .from("students")
      .update({ special_needs: ["ASD"] })
      .eq("id", b.studentRowId);

    const { data } = await b.admin.client
      .from("students").select("special_needs").eq("id", b.studentRowId).single();
    assertEquals(data!.special_needs, [], "cross-school write must not land");
  } finally {
    await Promise.all([a.dispose(), b.dispose()]);
  }
});
