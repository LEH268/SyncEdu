-- Phase 3 whole-branch review fixes.
--
-- 1. sweep_pending_ingestions: claim each row before dispatching. The 90s
--    "in-flight" gap did not work because the handler's first write for a
--    stage lands at the END of that stage, so a stuck-looking row was
--    dispatched again by the next sweep. Now the sweep itself bumps
--    updated_at = now() as it claims the row, so the next sweep's
--    `updated_at < now() - 90s` filter excludes it for a genuine 90s.
--    Plain create-or-replace: the 'ingest-sweep' cron job already targets
--    this function name, so no re-schedule.
-- 2. Explicit GRANTs for tables whose privileges used to ride on
--    auto_expose_new_tables (removed 2026-10-30); matches migration 0004.
-- 3. storage_school_id: guard the ::uuid cast so a non-UUID first path
--    segment yields NULL instead of raising 22P02.

create or replace function public.sweep_pending_ingestions()
returns integer
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_material   record;
  v_url        text;
  v_key        text;
  v_dispatched integer := 0;
begin
  select decrypted_secret into v_url
    from vault.decrypted_secrets where name = 'project_url';
  select decrypted_secret into v_key
    from vault.decrypted_secrets where name = 'service_role_key';

  if v_url is null or v_key is null then
    raise warning 'sweep_pending_ingestions: vault secrets missing; skipping';
    return 0;
  end if;

  -- Claim each row (updated_at := now()) before dispatching, so a concurrent
  -- sweep's `updated_at < now() - 90s` filter excludes it while it is in
  -- flight -- a real double-dispatch guard.
  for v_material in
    update public.materials
       set updated_at = now()
     where id in (
       select id from public.materials
        where deleted_at is null
          and (
            (ingestion_status in ('pending', 'pack_ready', 'pool_ready') and attempts < 3)
            or (ingestion_status = 'failed' and attempts < 8 and updated_at < now() - interval '30 minutes')
          )
          and updated_at < now() - interval '90 seconds'
        order by updated_at
        limit 5
     )
    returning id
  loop
    perform net.http_post(
      url     := v_url || '/functions/v1/ingest-material',
      headers := jsonb_build_object(
                   'Content-Type',  'application/json',
                   'Authorization', 'Bearer ' || v_key
                 ),
      body    := jsonb_build_object('materialId', v_material.id),
      timeout_milliseconds := 300000
    );
    v_dispatched := v_dispatched + 1;
  end loop;

  return v_dispatched;
end;
$$;

revoke execute on function public.sweep_pending_ingestions from anon, authenticated;

-- ── explicit grants (see migration 0004) ──────────────────────────────────
grant select on public.subjects to authenticated;
grant select on public.chapters to authenticated;
grant select on public.classes to authenticated;
grant select on public.class_subjects to authenticated;
grant select on public.knowledge_packs to authenticated;
grant select on public.micro_skills to authenticated;
grant select on public.micro_skill_explanations to authenticated;
grant select on public.questions to authenticated;
grant select, insert, update, delete on public.class_chapter_sched to authenticated;
grant select, insert, update, delete on public.materials to authenticated;

-- ── storage_school_id: guard the cast ─────────────────────────────────────
create or replace function public.storage_school_id(p_name text)
returns uuid
language sql
immutable
as $$
  select case
    when split_part(p_name, '/', 1) ~ '^[0-9a-fA-F-]{36}$'
    then split_part(p_name, '/', 1)::uuid
  end;
$$;
