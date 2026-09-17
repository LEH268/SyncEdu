-- Sync infrastructure: the conflict log, the writable-field whitelist, and
-- the single RPC through which every tier-2 and tier-3 field is written.

-- ── the whitelist ─────────────────────────────────────────────────────────
-- apply_delta composes dynamic SQL from a table and field name. This table is
-- what makes that safe: nothing outside it is ever interpolated, and every
-- identifier that is goes through format(%I).
create table public.sync_writable_fields (
  table_name text not null,
  field      text not null,
  tier       integer not null check (tier in (2, 3)),
  primary key (table_name, field)
);

-- class_id is deliberately not seeded yet: public.students has no such
-- column until the academic-structure migration (see 0001_tenancy.sql).
-- sync_writable_fields is world-readable so clients can discover syncable
-- fields, so seeding a field that does not exist would let any client walk
-- straight into an unhandled 42703 from apply_delta's dynamic SQL. Add it
-- back in the migration that adds the column.
insert into public.sync_writable_fields (table_name, field, tier) values
  ('students', 'special_needs',      3),
  ('students', 'special_needs_note', 3);

-- Readable by everyone so a client can tell which fields are syncable.
alter table public.sync_writable_fields enable row level security;
create policy sync_writable_fields_select on public.sync_writable_fields
  for select to authenticated using (true);

-- ── the conflict log ──────────────────────────────────────────────────────
create table public.sync_conflicts (
  id              uuid primary key default gen_random_uuid(),
  school_id       uuid not null references public.schools (id) on delete cascade,
  table_name      text not null,
  row_id          uuid not null,
  field           text not null,
  observed_value  jsonb,
  attempted_value jsonb,
  server_value    jsonb,
  attempted_by    uuid not null references auth.users (id) on delete cascade,
  attempted_at    timestamptz not null default now(),
  resolved_at     timestamptz,
  resolution      text,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  deleted_at      timestamptz
);

create index sync_conflicts_watermark_idx
  on public.sync_conflicts (school_id, updated_at);

create trigger sync_conflicts_set_updated_at
  before update on public.sync_conflicts
  for each row execute function public.set_updated_at();

alter table public.sync_conflicts enable row level security;

create policy sync_conflicts_select on public.sync_conflicts
  for select to authenticated
  using (school_id = public.jwt_school_id());

create policy sync_conflicts_resolve on public.sync_conflicts
  for update to authenticated
  using (
    school_id = public.jwt_school_id()
    and public.jwt_user_role() in ('admin', 'teacher')
  )
  with check (school_id = public.jwt_school_id());

-- apply_delta runs security invoker, so logging a conflict is an insert made
-- by the calling user, not the function owner. Without this policy every
-- conflict/superseded write would fail closed with a raw RLS error instead
-- of the intended jsonb response. school_id is always the row's own school
-- (read back under the caller's RLS a moment earlier), so this can never be
-- used to log a conflict against another school. attempted_by = auth.uid()
-- is required too, so this policy cannot be used from outside apply_delta
-- (e.g. a direct PostgREST insert) to forge a conflict record attributed to
-- someone else.
create policy sync_conflicts_insert on public.sync_conflicts
  for insert to authenticated
  with check (
    school_id = public.jwt_school_id()
    and attempted_by = auth.uid()
  );

-- Explicit grants, matching the pattern in 0004_explicit_grants.sql: RLS
-- above already scopes every one of these operations, but the underlying
-- privilege must still exist for RLS to have something to gate, and this
-- project cannot rely on the deprecated auto_expose_new_tables default.
grant select on public.sync_writable_fields to authenticated;
grant select, insert, update on public.sync_conflicts to authenticated;

-- ── apply_delta ───────────────────────────────────────────────────────────
-- security invoker, so RLS decides both what the caller may read and what
-- they may write. The function adds conflict semantics on top; it grants
-- nothing.
create or replace function public.apply_delta(
  p_table     text,
  p_row_id    uuid,
  p_field     text,
  p_observed  jsonb,
  p_new       jsonb,
  p_client_ts timestamptz
)
returns jsonb
language plpgsql
security invoker
as $$
declare
  v_tier       integer;
  v_current    jsonb;
  v_updated_at timestamptz;
  v_school     uuid;
  v_row_count  integer;
begin
  select tier into v_tier
    from public.sync_writable_fields
   where table_name = p_table
     and field = p_field;

  if v_tier is null then
    return jsonb_build_object('status', 'forbidden');
  end if;

  -- Read + lock the row through RLS. If the caller cannot see the row,
  -- nothing is found and no server value is disclosed.
  --
  -- FOR UPDATE is what makes the tier-3 compare-and-set below atomic: it is
  -- authorized against the caller's SELECT policy, not the UPDATE policy
  -- (so a caller who cannot even read the row still gets not_visible here,
  -- same as without the lock), and it is held across the compare-then-write
  -- that follows, so a concurrent apply_delta call on the same row blocks
  -- until this one finishes instead of both racing past a stale read and
  -- silently losing one writer's update.
  --
  -- Row-count check note: PL/pgSQL's FOUND variable is not updated by a
  -- dynamic EXECUTE ... INTO (confirmed empirically against this project's
  -- Postgres -- FOUND simply keeps whatever value the *previous* statement,
  -- here the whitelist lookup above, left it at, which is always true). Using
  -- GET DIAGNOSTICS ... ROW_COUNT instead gives the actual row count of this
  -- statement, which is what "if not found" was meant to express.
  execute format(
    'select to_jsonb(t.%I), t.updated_at, t.school_id from public.%I t where t.id = $1 for update',
    p_field, p_table
  )
  into v_current, v_updated_at, v_school
  using p_row_id;
  get diagnostics v_row_count = row_count;

  if v_row_count = 0 then
    return jsonb_build_object('status', 'not_visible');
  end if;

  if v_tier = 3 and v_current is distinct from p_observed then
    insert into public.sync_conflicts (
      school_id, table_name, row_id, field,
      observed_value, attempted_value, server_value, attempted_by
    ) values (
      v_school, p_table, p_row_id, p_field,
      p_observed, p_new, v_current, auth.uid()
    );
    return jsonb_build_object('status', 'conflict', 'server_value', v_current);
  end if;

  if v_tier = 2 and v_updated_at > p_client_ts then
    -- Last-writer-wins, and this writer is not it. The value is not dropped
    -- silently: it is recorded so the owner can see what was overwritten.
    insert into public.sync_conflicts (
      school_id, table_name, row_id, field,
      observed_value, attempted_value, server_value, attempted_by
    ) values (
      v_school, p_table, p_row_id, p_field,
      p_observed, p_new, v_current, auth.uid()
    );
    return jsonb_build_object('status', 'superseded', 'server_value', v_current);
  end if;

  -- The value matched (tier 3) or last-writer-wins passed (tier 2). The
  -- FOR UPDATE lock held since the read above means no other apply_delta
  -- call can interleave here, so this UPDATE needs no value precondition of
  -- its own -- it either writes, or fails because RLS (not a stale value)
  -- refuses it, which is reported as not_visible below, distinct from a
  -- value conflict.
  --
  -- jsonb_populate_record converts the value using the table's own
  -- rowtype, so text[], timestamptz and integer columns all work without
  -- the caller knowing the column's type.
  execute format(
    'update public.%I t
        set %I = (jsonb_populate_record(null::public.%I, jsonb_build_object(%L, $1))).%I
      where t.id = $2',
    p_table, p_field, p_table, p_field, p_field
  )
  using p_new, p_row_id;
  get diagnostics v_row_count = row_count;

  if v_row_count = 0 then
    -- RLS allowed the read but refused the write.
    return jsonb_build_object('status', 'not_visible');
  end if;

  -- version is bumped separately because not every writable table has one.
  -- (No ROW_COUNT check here: an UPDATE ... WHERE id = $1 on a row we just
  -- wrote to in this same statement is always exactly one row.)
  if exists (
    select 1 from information_schema.columns
     where table_schema = 'public' and table_name = p_table and column_name = 'version'
  ) then
    execute format('update public.%I set version = version + 1 where id = $1', p_table)
      using p_row_id;
  end if;

  return jsonb_build_object('status', 'applied');
end;
$$;

-- Postgres grants EXECUTE on new functions to PUBLIC by default, so revoking
-- only from anon would leave anon executing via PUBLIC. Revoke from both, as
-- 0002_access_token_hook.sql already does for its own functions.
revoke execute on function public.apply_delta(text, uuid, text, jsonb, jsonb, timestamptz) from public, anon;
grant execute on function public.apply_delta(text, uuid, text, jsonb, jsonb, timestamptz) to authenticated;
