import { createClient, type SupabaseClient } from "jsr:@supabase/supabase-js@2";

export interface ProvisionRequestUser {
  email: string;
  fullName: string;
  role: string;
}

export interface ProvisionedUser {
  userId: string;
  email: string;
  role: string;
  temporaryPassword: string;
}

const CORS_HEADERS: Record<string, string> = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS_HEADERS, "content-type": "application/json" },
  });
}

function serviceClient(): SupabaseClient {
  return createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    { auth: { persistSession: false, autoRefreshToken: false } },
  );
}

/// A password the administrator hands to the user on first sign-in. Long
/// enough to satisfy any policy, and drawn from the CSPRNG rather than
/// Math.random.
function generateTemporaryPassword(): string {
  const bytes = crypto.getRandomValues(new Uint8Array(15));
  const body = btoa(String.fromCharCode(...bytes)).replace(/[^A-Za-z0-9]/g, "");
  return `${body.slice(0, 14)}aA1!`;
}

export async function handler(req: Request): Promise<Response> {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: CORS_HEADERS });
  }
  if (req.method !== "POST") {
    return json({ error: "method_not_allowed" }, 405);
  }

  const authorization = req.headers.get("Authorization");
  if (!authorization?.startsWith("Bearer ")) {
    return json({ error: "unauthorized" }, 401);
  }

  const service = serviceClient();

  const { data: caller, error: callerError } = await service.auth.getUser(
    authorization.slice("Bearer ".length),
  );
  if (callerError || !caller.user) {
    return json({ error: "unauthorized" }, 401);
  }

  // Authorise against the database rather than the token's claims: this is the
  // one function that can create accounts, so it verifies against the source
  // of truth every time.
  const { data: callerProfile } = await service
    .from("profiles")
    .select("school_id, role")
    .eq("id", caller.user.id)
    .is("deleted_at", null)
    .maybeSingle();

  if (!callerProfile || callerProfile.role !== "admin") {
    return json({ error: "forbidden" }, 403);
  }

  let body: { users?: ProvisionRequestUser[] };
  try {
    body = await req.json();
  } catch {
    return json({ error: "invalid_json" }, 400);
  }
  if (!Array.isArray(body.users) || body.users.length === 0) {
    return json({ error: "no_users" }, 400);
  }

  const created: ProvisionedUser[] = [];
  const failed: Array<{ email: string; reason: string }> = [];

  for (const requested of body.users) {
    const temporaryPassword = generateTemporaryPassword();

    const { data: authUser, error: createError } = await service.auth.admin
      .createUser({
        email: requested.email,
        password: temporaryPassword,
        email_confirm: true,
      });

    if (createError || !authUser.user) {
      failed.push({
        email: requested.email,
        reason: createError?.message ?? "create_user_failed",
      });
      continue;
    }

    const { error: profileError } = await service.from("profiles").insert({
      id: authUser.user.id,
      school_id: callerProfile.school_id,
      role: requested.role,
      full_name: requested.fullName,
      email: requested.email,
    });

    if (profileError) {
      // The Admin API and the database cannot share a transaction, so undo the
      // auth user rather than leaving an account with no profile behind.
      await service.auth.admin.deleteUser(authUser.user.id);
      failed.push({ email: requested.email, reason: profileError.message });
      continue;
    }

    if (requested.role === "student") {
      const { error: studentError } = await service.from("students").insert({
        id: crypto.randomUUID(),
        school_id: callerProfile.school_id,
        profile_id: authUser.user.id,
      });
      if (studentError) {
        await service.auth.admin.deleteUser(authUser.user.id);
        failed.push({ email: requested.email, reason: studentError.message });
        continue;
      }
    }

    created.push({
      userId: authUser.user.id,
      email: requested.email,
      role: requested.role,
      temporaryPassword,
    });
  }

  const status = created.length === 0 && failed.length > 0 ? 422 : 200;
  return json({ created, failed }, status);
}
