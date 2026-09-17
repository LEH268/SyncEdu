import { createClient } from "@supabase/supabase-js";

const url = Deno.env.get("SUPABASE_URL")!;
const service = createClient(url, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!, {
  auth: { persistSession: false },
});

const PASSWORD = "SyncEdu-Demo-1!";
const schoolId = crypto.randomUUID();

await service.from("schools").insert({
  id: schoolId,
  name: "SMK Demo",
  education_level: "secondary",
});

for (const role of ["admin", "teacher", "student"] as const) {
  const email = `${role}@demo.syncedu.invalid`;

  const existing = await service.auth.admin.listUsers({ page: 1, perPage: 200 });
  const found = existing.data.users.find((u) => u.email === email);
  if (found) await service.auth.admin.deleteUser(found.id);

  const { data, error } = await service.auth.admin.createUser({
    email,
    password: PASSWORD,
    email_confirm: true,
  });
  if (error) throw error;

  await service.from("profiles").insert({
    id: data.user!.id,
    school_id: schoolId,
    role,
    full_name: `Demo ${role}`,
    email,
  });

  if (role === "student") {
    await service.from("students").insert({
      id: crypto.randomUUID(),
      school_id: schoolId,
      profile_id: data.user!.id,
    });
  }

  console.log(`${email} / ${PASSWORD}`);
}

console.log(`school_id: ${schoolId}`);
