import { createClient, type SupabaseClient } from "@supabase/supabase-js";

function required(name: string): string {
  const value = Deno.env.get(name);
  if (!value) {
    throw new Error(
      `Missing ${name}. Copy .env.example to .env, fill it in, and run tests ` +
        `via \`deno task test:seam\` so --env-file=.env is applied.`,
    );
  }
  return value;
}

export const supabaseUrl = (): string => required("SUPABASE_URL");
export const anonKey = (): string => required("SUPABASE_ANON_KEY");

/// Service-role client. Bypasses row-level security entirely, so use it only
/// for fixture setup and teardown -- never for the assertion under test, or
/// the test proves nothing about access control.
export function admin(): SupabaseClient {
  return createClient(supabaseUrl(), required("SUPABASE_SERVICE_ROLE_KEY"), {
    auth: { persistSession: false, autoRefreshToken: false },
  });
}

export interface TestUser {
  /** auth.users.id, which is also profiles.id. */
  id: string;
  email: string;
  password: string;
  /** A client signed in as this user, so RLS applies to everything it does. */
  client: SupabaseClient;
}

export interface TestSchool {
  id: string;
  admin: TestUser;
  teacher: TestUser;
  student: TestUser;
  /** students.id for the student user, which is not the same as their auth id. */
  studentRowId: string;
  dispose(): Promise<void>;
}

const TEST_EMAIL_DOMAIN = "test.syncedu.invalid";
const TEST_PASSWORD = "seam-Test-Password-1!";

async function createUser(
  service: SupabaseClient,
  schoolId: string,
  role: "student" | "teacher" | "admin",
  label: string,
): Promise<TestUser> {
  const email = `${role}-${label}-${crypto.randomUUID()}@${TEST_EMAIL_DOMAIN}`;

  const { data: created, error: createError } = await service.auth.admin
    .createUser({ email, password: TEST_PASSWORD, email_confirm: true });
  if (createError || !created.user) {
    throw new Error(`Could not create ${role}: ${createError?.message}`);
  }

  const { error: profileError } = await service.from("profiles").insert({
    id: created.user.id,
    school_id: schoolId,
    role,
    full_name: `Seam ${role}`,
    email,
  });
  if (profileError) {
    await service.auth.admin.deleteUser(created.user.id);
    throw new Error(`Could not create ${role} profile: ${profileError.message}`);
  }

  // Sign in only after the profile exists, so the access token hook has a row
  // to read and the claims are populated on the very first token.
  const client = createClient(supabaseUrl(), anonKey(), {
    auth: { persistSession: false, autoRefreshToken: false },
  });

  // The real limiter tripping under normal seam-suite load is not the
  // configurable `sign_in_sign_ups` ceiling (confirmed by raising it from 200
  // to 500 with no change in behaviour) -- something with a much lower
  // effective threshold rejects bursts of sign-ins with "Request rate limit
  // reached". Rather than keep chasing an unknown limiter via config, retry
  // the sign-in itself with exponential backoff so a transient 429 does not
  // fail the whole fixture.
  const MAX_SIGN_IN_ATTEMPTS = 5;
  let lastError: { message: string } | null = null;
  for (let attempt = 0; attempt < MAX_SIGN_IN_ATTEMPTS; attempt++) {
    const { error: signInError } = await client.auth.signInWithPassword({
      email,
      password: TEST_PASSWORD,
    });
    if (!signInError) {
      lastError = null;
      break;
    }
    lastError = signInError;
    const isRateLimited = signInError.status === 429 ||
      /rate limit/i.test(signInError.message);
    if (!isRateLimited || attempt === MAX_SIGN_IN_ATTEMPTS - 1) {
      break;
    }
    const backoffMs = 1000 * 2 ** attempt; // 1s, 2s, 4s, 8s
    await new Promise((resolve) => setTimeout(resolve, backoffMs));
  }
  if (lastError) {
    throw new Error(`Could not sign in ${role}: ${lastError.message}`);
  }

  return { id: created.user.id, email, password: TEST_PASSWORD, client };
}

/// Creates an isolated school with one admin, one teacher and one student.
/// Always call `dispose()` in a `finally` block.
export async function createTestSchool(label = "seam"): Promise<TestSchool> {
  const service = admin();
  const schoolId = crypto.randomUUID();

  const { error: schoolError } = await service.from("schools").insert({
    id: schoolId,
    name: `Seam School ${label}`,
    education_level: "secondary",
  });
  if (schoolError) {
    throw new Error(`Could not create test school: ${schoolError.message}`);
  }

  const adminUser = await createUser(service, schoolId, "admin", label);
  const teacherUser = await createUser(service, schoolId, "teacher", label);
  const studentUser = await createUser(service, schoolId, "student", label);

  const studentRowId = crypto.randomUUID();
  const { error: studentError } = await service.from("students").insert({
    id: studentRowId,
    school_id: schoolId,
    profile_id: studentUser.id,
  });
  if (studentError) {
    throw new Error(`Could not create student row: ${studentError.message}`);
  }

  return {
    id: schoolId,
    admin: adminUser,
    teacher: teacherUser,
    student: studentUser,
    studentRowId,
    async dispose(): Promise<void> {
      // Deleting the auth users cascades to profiles and then to students;
      // deleting the school cascades to anything else school-scoped. Both are
      // attempted regardless of individual failures so one bad row cannot
      // strand an entire school in the shared project.
      for (const user of [adminUser, teacherUser, studentUser]) {
        await service.auth.admin.deleteUser(user.id).catch(() => {});
      }
      await service.from("schools").delete().eq("id", schoolId);
    },
  };
}
