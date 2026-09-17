-- Explicit grants for the `authenticated` role, so these tables remain
-- readable/writable (subject to RLS) even after auto_expose_new_tables is
-- removed (Supabase config.toml documents removal on 2026-10-30). RLS
-- policies from migration 0003 already scope every one of these operations
-- to the caller's own school; this migration only ensures the privilege
-- exists for RLS to gate, matching what the policies already assume.
grant select on public.schools to authenticated;
grant select on public.profiles to authenticated;
grant select, update on public.students to authenticated;
