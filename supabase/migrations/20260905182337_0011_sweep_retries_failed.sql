-- Make the sweep retry `failed` materials too, with backoff.
--
-- "Ingestion is resumable, not transactional." A material can land in `failed`
-- on a purely transient upstream condition (all Gemini keys hitting a shared
-- daily quota). The handler now avoids marking such cases `failed`, but any
-- material already stuck there -- or failed by some other transient blip --
-- should still get another chance. We re-select `failed` rows with a capped
-- attempt count and a 30-minute cooldown so a genuinely broken material is not
-- hammered forever.
--
-- The cron job ('ingest-sweep') is already registered against this function
-- name, so this is a plain create-or-replace: no re-schedule.

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
     where deleted_at is null
       and (
         (ingestion_status in ('pending', 'pack_ready', 'pool_ready') and attempts < 3)
         or (ingestion_status = 'failed' and attempts < 8 and updated_at < now() - interval '30 minutes')
       )
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
