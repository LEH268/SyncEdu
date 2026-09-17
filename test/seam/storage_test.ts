import { assert, assertEquals } from "@std/assert";
import { admin, createTestSchool } from "./harness.ts";

Deno.test("a teacher can upload into their own school's prefix", async () => {
  const school = await createTestSchool("upload");
  const path = `${school.id}/${crypto.randomUUID()}.pdf`;
  try {
    const { error } = await school.teacher.client.storage
      .from("materials")
      .upload(
        path,
        new Blob([new Uint8Array([37, 80, 68, 70])], {
          type: "application/pdf",
        }),
        { contentType: "application/pdf" },
      );
    assertEquals(error, null);

    const { data } = await school.teacher.client.storage
      .from("materials").list(school.id);
    assert(data!.length >= 1);
  } finally {
    await admin().storage.from("materials").remove([path]);
    await school.dispose();
  }
});

Deno.test("a teacher cannot upload into another school's prefix", async () => {
  const [a, b] = await Promise.all([
    createTestSchool("st-a"),
    createTestSchool("st-b"),
  ]);
  const path = `${b.id}/${crypto.randomUUID()}.pdf`;
  try {
    const { error } = await a.teacher.client.storage
      .from("materials")
      .upload(
        path,
        new Blob([new Uint8Array([37, 80, 68, 70])], {
          type: "application/pdf",
        }),
        { contentType: "application/pdf" },
      );
    assert(error !== null, "a cross-school upload must be refused");
  } finally {
    await admin().storage.from("materials").remove([path]);
    await Promise.all([a.dispose(), b.dispose()]);
  }
});

Deno.test("a student cannot read the materials bucket at all", async () => {
  const school = await createTestSchool("st-student");
  const path = `${school.id}/${crypto.randomUUID()}.pdf`;
  try {
    await admin().storage.from("materials")
      .upload(
        path,
        new Blob([new Uint8Array([37, 80, 68, 70])], {
          type: "application/pdf",
        }),
        { contentType: "application/pdf" },
      );

    const { data } = await school.student.client.storage
      .from("materials").list(school.id);

    // Students consume the Knowledge Pack, never the source file.
    assertEquals(data?.length ?? 0, 0);
  } finally {
    await admin().storage.from("materials").remove([path]);
    await school.dispose();
  }
});
