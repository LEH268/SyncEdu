-- Explicit grants for the activity tables introduced in 0013.
--
-- 0013 enables RLS and writes the policies, but never grants the base
-- privileges those policies gate. RLS narrows a privilege; it cannot create
-- one. While `auto_expose_new_tables` is still on, the tables happen to be
-- reachable anyway -- but that flag is removed on 2026-10-30 (see
-- supabase/config.toml), and on that day the authenticated role would lose
-- `insert` on attempts/attempt_items and `select` on weaknesses, silently
-- stranding every quiz attempt in the outbox.
--
-- Written as a new migration rather than an edit to 0013, which is already
-- applied -- the same convention migration 0012 followed for 0004's grants.
--
-- No `insert`/`update`/`delete` on weaknesses: those rows are derived by
-- `public.recompute_weaknesses`, which is `security definer`. Clients read
-- them and nothing more.
grant select, insert on public.attempts to authenticated;
grant select, insert on public.attempt_items to authenticated;
grant select on public.weaknesses to authenticated;
