-- Row-level security for the tenancy tables.
--
-- Postgres denies by default once RLS is enabled, so the absence of a policy
-- is itself the rule: no INSERT or DELETE policy exists here because accounts
-- are created only by the provision-users Edge Function, which uses the
-- service role and bypasses RLS entirely.

alter table public.schools  enable row level security;
alter table public.profiles enable row level security;
alter table public.students enable row level security;

-- The access-token hook (migration 0002) runs as supabase_auth_admin and
-- reads profiles to build the school_id/user_role claims. It is not the
-- `authenticated` role and has no BYPASSRLS, so without this policy RLS
-- silently hides every row from the hook once RLS is enabled above --
-- every token then comes back with no custom claims, and every policy that
-- depends on those claims fails closed (denies everything) rather than
-- enforcing tenancy.
create policy profiles_select_for_auth_hook on public.profiles
  for select to supabase_auth_admin
  using (true);

-- A school is readable by its own members.
create policy schools_select on public.schools
  for select to authenticated
  using (id = public.jwt_school_id());

-- Profiles are readable across one's own school. Rosters, teacher lists and
-- the relationship diagram all read from here.
create policy profiles_select on public.profiles
  for select to authenticated
  using (school_id = public.jwt_school_id());

-- Staff read the whole school; a student reads only their own row.
-- Teacher scope narrows to taught classes once class_subjects exists.
create policy students_select on public.students
  for select to authenticated
  using (
    school_id = public.jwt_school_id()
    and (
      public.jwt_user_role() in ('admin', 'teacher')
      or profile_id = auth.uid()
    )
  );

-- Only an admin may change a student record. The tier-3 delta path narrows
-- this to whitelisted fields when the sync layer lands; until then the whole
-- row is admin-only. USING governs which rows are visible to the update;
-- WITH CHECK governs the row's state afterwards, so both are required to stop
-- an admin moving a row into another school.
create policy students_update on public.students
  for update to authenticated
  using (
    school_id = public.jwt_school_id()
    and public.jwt_user_role() = 'admin'
  )
  with check (
    school_id = public.jwt_school_id()
    and public.jwt_user_role() = 'admin'
  );
