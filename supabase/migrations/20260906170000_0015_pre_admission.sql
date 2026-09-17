-- The Pre-admission Test result (spec §5, §8.1).
--
-- Append-only (tier 1): a student sits the instrument once, offline, and the
-- row replays idempotently on its client-supplied id. Scoring is pure Dart in
-- syncedu_core; this table only stores the tallies it produced.

create table public.pre_admission_results (
  id            uuid primary key,
  school_id     uuid not null references public.schools (id) on delete cascade,
  student_id    uuid not null references public.students (id) on delete cascade,
  -- Raw VARK tallies, keyed 'V','A','R','K'.
  vark          jsonb not null default '{}'::jsonb,
  structured    integer not null default 0,
  exploratory   integer not null default 0,
  introvert     integer not null default 0,
  extrovert     integer not null default 0,
  impulsivity   integer not null default 0,
  reflectivity  integer not null default 0,
  dominant_style text not null check (dominant_style in ('V', 'A', 'R', 'K')),
  -- The chosen option index per question, kept so a re-score is possible if
  -- the scoring ever changes.
  answers       integer[] not null default '{}',
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  deleted_at    timestamptz,
  unique (student_id)
);
create index pre_admission_results_watermark_idx
  on public.pre_admission_results (school_id, updated_at);
create trigger pre_admission_results_set_updated_at
  before update on public.pre_admission_results
  for each row execute function public.set_updated_at();

-- Completing the instrument lifts the router gate. Stamped here rather than by
-- the client so the gate cannot be bypassed by writing the flag directly.
create or replace function public.mark_pre_admission_complete()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.students
     set pre_admission_completed_at = coalesce(pre_admission_completed_at, now())
   where id = new.student_id
     and pre_admission_completed_at is null;
  return new;
end;
$$;

create trigger pre_admission_results_mark_complete
  after insert on public.pre_admission_results
  for each row execute function public.mark_pre_admission_complete();

alter table public.pre_admission_results enable row level security;

create policy pre_admission_results_select on public.pre_admission_results
  for select to authenticated using (public.may_read_student(student_id));

create policy pre_admission_results_insert on public.pre_admission_results
  for insert to authenticated
  with check (
    school_id = public.jwt_school_id()
    and exists (
      select 1 from public.students s
       where s.id = pre_admission_results.student_id
         and s.profile_id = auth.uid()
    )
  );

grant select, insert on public.pre_admission_results to authenticated;
