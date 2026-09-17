-- The exam-paper loop (spec §5, §6.3, plan Task 6).
--
-- A teacher uploads a marked paper; analyse-exam-paper reads it, maps the
-- errors onto the chapter's EXISTING micro-skill slugs under the same
-- enumerated constraint and composite foreign key as question generation, and
-- writes weakness rows with source = 'exam'. No parallel taxonomy: a second
-- vocabulary would fragment every aggregate the product rests on.

create table public.exam_papers (
  id               uuid primary key,
  school_id        uuid not null references public.schools (id) on delete cascade,
  student_id       uuid not null references public.students (id) on delete cascade,
  chapter_id       uuid not null references public.chapters (id) on delete cascade,
  storage_path     text not null,
  analysis_status  text not null default 'pending'
                     check (analysis_status in ('pending', 'analysed', 'failed')),
  analysis_note    text,
  attempts         integer not null default 0,
  uploaded_by      uuid not null references public.profiles (id) on delete cascade,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),
  deleted_at       timestamptz
);
create index exam_papers_watermark_idx on public.exam_papers (school_id, updated_at);
create index exam_papers_pending_idx on public.exam_papers (analysis_status, updated_at)
  where analysis_status = 'pending' and deleted_at is null;
create trigger exam_papers_set_updated_at before update on public.exam_papers
  for each row execute function public.set_updated_at();

alter table public.exam_papers enable row level security;

-- A teacher may upload for a student in a class they teach; the student and
-- admins may read; students never upload.
create or replace function public.teaches_student(p_student_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.students s
     where s.id = p_student_id
       and s.school_id = public.jwt_school_id()
       and s.class_id is not null
       and public.teaches_class(s.class_id)
  );
$$;

create policy exam_papers_select on public.exam_papers
  for select to authenticated using (public.may_read_student(student_id));

create policy exam_papers_insert on public.exam_papers
  for insert to authenticated
  with check (
    school_id = public.jwt_school_id()
    and uploaded_by = auth.uid()
    and (public.jwt_user_role() = 'admin' or public.teaches_student(student_id))
  );

grant select, insert on public.exam_papers to authenticated;

-- ── cron sweep ────────────────────────────────────────────────────────────
-- Mirrors sweep_pending_ingestions from migration 0008: pg_cron sweeps
-- pending papers every minute through pg_net, one invocation per paper.
create or replace function public.sweep_pending_exam_papers()
returns integer
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_paper      record;
  v_url        text;
  v_key        text;
  v_dispatched integer := 0;
begin
  select decrypted_secret into v_url
    from vault.decrypted_secrets where name = 'project_url';
  select decrypted_secret into v_key
    from vault.decrypted_secrets where name = 'service_role_key';

  if v_url is null or v_key is null then
    raise warning 'sweep_pending_exam_papers: vault secrets missing; skipping';
    return 0;
  end if;

  for v_paper in
    select id
      from public.exam_papers
     where analysis_status = 'pending'
       and deleted_at is null
       and attempts < 3
       and updated_at < now() - interval '90 seconds'
     order by updated_at
     limit 5
  loop
    perform net.http_post(
      url     := v_url || '/functions/v1/analyse-exam-paper',
      headers := jsonb_build_object(
                   'Content-Type',  'application/json',
                   'Authorization', 'Bearer ' || v_key
                 ),
      body    := jsonb_build_object('examPaperId', v_paper.id),
      timeout_milliseconds := 300000
    );
    v_dispatched := v_dispatched + 1;
  end loop;

  return v_dispatched;
end;
$$;

revoke execute on function public.sweep_pending_exam_papers from anon, authenticated;

select cron.schedule(
  'exam-paper-sweep',
  '* * * * *',
  $$select public.sweep_pending_exam_papers();$$
);
