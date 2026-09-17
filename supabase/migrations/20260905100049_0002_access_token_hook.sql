-- The access token hook and the two claim readers every RLS policy uses.
--
-- CRITICAL: the application role travels as `user_role`, never `role`. The
-- JWT's top-level `role` claim holds `authenticated`, and PostgREST switches
-- the Postgres role based on it. Overwriting that claim breaks every
-- authenticated request in the system.

create or replace function public.custom_access_token_hook(event jsonb)
returns jsonb
language plpgsql
stable
as $$
declare
  v_claims  jsonb;
  v_school  uuid;
  v_role    text;
begin
  select p.school_id, p.role
    into v_school, v_role
    from public.profiles p
   where p.id = (event ->> 'user_id')::uuid
     and p.deleted_at is null;

  v_claims := event -> 'claims';

  -- A user with no profile (or a soft-deleted one) gets an ordinary token with
  -- no custom claims. Every RLS policy compares against school_id, so such a
  -- token reads nothing rather than reading everything.
  if v_school is not null then
    v_claims := jsonb_set(v_claims, '{school_id}', to_jsonb(v_school::text));
    v_claims := jsonb_set(v_claims, '{user_role}', to_jsonb(v_role));
  end if;

  return jsonb_set(event, '{claims}', v_claims);
end;
$$;

-- Auth runs the hook as supabase_auth_admin, which therefore needs to reach
-- the function and the table it reads. Nobody else may execute it.
grant usage on schema public to supabase_auth_admin;
grant execute on function public.custom_access_token_hook (jsonb) to supabase_auth_admin;
grant select on table public.profiles to supabase_auth_admin;

revoke execute on function public.custom_access_token_hook (jsonb)
  from authenticated, anon, public;

-- ── claim readers ─────────────────────────────────────────────────────────
-- Used by every RLS policy, so the tenancy check is a claim comparison rather
-- than a join back to profiles.
create or replace function public.jwt_school_id()
returns uuid
language sql
stable
as $$
  select nullif(auth.jwt() ->> 'school_id', '')::uuid;
$$;

create or replace function public.jwt_user_role()
returns text
language sql
stable
as $$
  select auth.jwt() ->> 'user_role';
$$;
