-- Drives the ingestion pipeline forward without anyone staying connected.
--
-- This is what makes the offline story work: a teacher who queues an upload on
-- a dead connection only has to land the file and insert a pending row. The
-- sweep does the rest, whether or not they are still there.

create extension if not exists pg_cron with schema extensions;
create extension if not exists pg_net  with schema extensions;

-- The service-role key is held in Vault, never in a migration or a table a
-- client could read.
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

  for v_material in
    select id
      from public.materials
     where ingestion_status in ('pending', 'pack_ready', 'pool_ready')
       and deleted_at is null
       and attempts < 3
       -- Leave a gap so a stage still running is not invoked twice.
       and updated_at < now() - interval '90 seconds'
     order by updated_at
     limit 5
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

select cron.schedule(
  'ingest-sweep',
  '* * * * *',
  $$select public.sweep_pending_ingestions();$$
);
