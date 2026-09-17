import { createClient, type SupabaseClient } from "jsr:@supabase/supabase-js@2";

import { HttpError } from "./http.ts";

export interface Caller {
  userId: string;
  schoolId: string;
  role: "student" | "teacher" | "admin";
}

export function serviceClient(): SupabaseClient {
  return createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    { auth: { persistSession: false, autoRefreshToken: false } },
  );
}

/// Verifies the caller's token and resolves their identity from the database
/// rather than from claims. Claims are enough for RLS; a function that acts
/// with the service role checks the source of truth.
export async function requireCaller(req: Request): Promise<Caller> {
  const authorization = req.headers.get("Authorization");
  if (!authorization?.startsWith("Bearer ")) {
    throw new HttpError(401, "unauthorized");
  }

  const service = serviceClient();
  const { data, error } = await service.auth.getUser(
    authorization.slice("Bearer ".length),
  );
  if (error || !data.user) throw new HttpError(401, "unauthorized");

  const { data: profile } = await service
    .from("profiles")
    .select("school_id, role")
    .eq("id", data.user.id)
    .is("deleted_at", null)
    .maybeSingle();

  if (!profile) throw new HttpError(403, "no_profile");

  return {
    userId: data.user.id,
    schoolId: profile.school_id as string,
    role: profile.role as Caller["role"],
  };
}

export function requireRole(caller: Caller, ...allowed: Caller["role"][]): void {
  if (!allowed.includes(caller.role)) throw new HttpError(403, "forbidden");
}

/// True when the bearer is a service_role JWT. The function gateway
/// (`verify_jwt`) has already verified the signature before the handler runs,
/// so decoding the payload without re-verifying is sufficient. Used by
/// functions a `pg_cron` sweep invokes, which authenticate as the service
/// role and have no profile row.
export function isServiceRoleBearer(authorization: string | null): boolean {
  try {
    if (!authorization?.startsWith("Bearer ")) return false;
    const payload = authorization.slice("Bearer ".length).split(".")[1];
    const decoded = atob(payload.replace(/-/g, "+").replace(/_/g, "/"));
    return JSON.parse(decoded).role === "service_role";
  } catch {
    return false;
  }
}

/// Verifies the caller may act on behalf of [studentId]: it is their own
/// student row, or a teacher of their class, or an admin of their school.
/// Evaluated against the already-verified caller rather than via RLS, because
/// these functions run with the service role across tables RLS does not
/// expose together. Returns the student row.
export async function assertMayActOnStudent(
  db: SupabaseClient,
  caller: Caller,
  studentId: string,
): Promise<Record<string, unknown>> {
  const { data: student } = await db
    .from("students")
    .select("id, school_id, profile_id, class_id, special_needs")
    .eq("id", studentId)
    .maybeSingle();

  if (!student || student.school_id !== caller.schoolId) {
    throw new HttpError(403, "forbidden");
  }
  if (student.profile_id === caller.userId || caller.role === "admin") {
    return student;
  }
  if (caller.role === "teacher" && student.class_id) {
    const { data: teaches } = await db
      .from("class_subjects")
      .select("id")
      .eq("class_id", student.class_id)
      .eq("teacher_id", caller.userId)
      .is("deleted_at", null)
      .maybeSingle();
    if (teaches) return student;
  }
  throw new HttpError(403, "forbidden");
}
