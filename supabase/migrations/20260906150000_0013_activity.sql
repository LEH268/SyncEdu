-- Activity: what a student did, item by item, and what it says about them.

create table public.attempts (
  id                uuid primary key,
  school_id         uuid not null references public.schools (id) on delete cascade,
  student_id        uuid not null references public.students (id) on delete cascade,
  chapter_ids       uuid[] not null default '{}',
  -- Computed at submission and never recomputed. Deriving this at read time
  -- would let a teacher backdating a taught_on silently reclassify last
  -- month's attempts and change a heatmap that has already been read.
  mode              text not null check (mode in ('prep', 'revise')),
  attempt_number    integer not null default 1 check (attempt_number > 0),
  parent_attempt_id uuid references public.attempts (id) on delete set null,
  question_count    integer not null check (question_count > 0),
  score             integer not null default 0 check (score >= 0),
  started_at        timestamptz not null default now(),
  submitted_at      timestamptz,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  deleted_at        timestamptz,
  constraint attempts_score_within_count check (score <= question_count)
);
create index attempts_watermark_idx on public.attempts (school_id, updated_at);
create index attempts_student_idx on public.attempts (student_id, submitted_at desc);
create index attempts_chain_idx on public.attempts (parent_attempt_id)
  where parent_attempt_id is not null;
create trigger attempts_set_updated_at before update on public.attempts
  for each row execute function public.set_updated_at();

create table public.attempt_items (
  id             uuid primary key,
  school_id      uuid not null references public.schools (id) on delete cascade,
  attempt_id     uuid not null references public.attempts (id) on delete cascade,
  question_id    uuid references public.questions (id) on delete set null,
  -- Deliberately denormalised. Every analytic in the product is a GROUP BY on
  -- this column, so no analytic should have to join through the question pool
  -- -- and the row survives a question being edited or tombstoned.
  micro_skill_id uuid not null references public.micro_skills (id) on delete cascade,
  selected_index integer,
  is_correct     boolean not null,
  ordinal        integer not null,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  deleted_at     timestamptz,
  unique (attempt_id, ordinal)
);
create index attempt_items_watermark_idx on public.attempt_items (school_id, updated_at);
create index attempt_items_skill_idx on public.attempt_items (micro_skill_id, is_correct);
create index attempt_items_attempt_idx on public.attempt_items (attempt_id);
create trigger attempt_items_set_updated_at before update on public.attempt_items
  for each row execute function public.set_updated_at();

-- ── the unified weakness store ────────────────────────────────────────────
-- Keyed by source as well as skill: keeping quiz-sourced and exam-sourced
-- rows apart is what lets the console show *why* a skill is flagged, and what
-- gives "writes to the same store with a different source marker" meaning.
create table public.weaknesses (
  id             uuid primary key,
  school_id      uuid not null references public.schools (id) on delete cascade,
  student_id     uuid not null references public.students (id) on delete cascade,
  micro_skill_id uuid not null references public.micro_skills (id) on delete cascade,
  weight         numeric(5, 4) not null check (weight >= 0 and weight <= 1),
  source         text not null check (source in ('quiz', 'exam')),
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  deleted_at     timestamptz,
  unique (student_id, micro_skill_id, source)
);
create index weaknesses_watermark_idx on public.weaknesses (school_id, updated_at);
create index weaknesses_student_idx on public.weaknesses (student_id, weight desc);
create trigger weaknesses_set_updated_at before update on public.weaknesses
  for each row execute function public.set_updated_at();

-- ── derivation ────────────────────────────────────────────────────────────
-- Weakness rows are never written by hand for source='quiz'. They are a
-- deterministic function of the student's attempt_items: an
-- exponentially-decayed error rate with a fourteen-day half-life, so old
-- mistakes fade as a student improves and a stale weakness cannot bias
-- generation forever.
--
-- The client computes the same formula locally so the student's own view
-- updates instantly offline. Because both sides read the same rows and apply
-- the same arithmetic, they agree rather than needing reconciliation.
create or replace function public.recompute_weaknesses(
  p_student_id uuid,
  p_micro_skill_id uuid
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_weight   numeric;
  v_school   uuid;
  v_half_life constant numeric := 14.0;
begin
  select s.school_id into v_school from public.students s where s.id = p_student_id;
  if v_school is null then return; end if;

  select
    case when sum(w) = 0 then 0
         else least(1.0, greatest(0.0, sum(w * (case when ai.is_correct then 0 else 1 end)) / sum(w)))
    end
  into v_weight
  from public.attempt_items ai
  join public.attempts a on a.id = ai.attempt_id
  cross join lateral (
    select power(0.5, extract(epoch from (now() - coalesce(a.submitted_at, a.created_at)))
                       / (v_half_life * 86400.0)) as w
  ) decay
  where a.student_id = p_student_id
    and ai.micro_skill_id = p_micro_skill_id
    and ai.deleted_at is null
    and a.deleted_at is null;

  if v_weight is null then return; end if;

  insert into public.weaknesses (
    id, school_id, student_id, micro_skill_id, weight, source
  ) values (
    gen_random_uuid(), v_school, p_student_id, p_micro_skill_id, v_weight, 'quiz'
  )
  on conflict (student_id, micro_skill_id, source)
  do update set weight = excluded.weight, updated_at = now();
end;
$$;

create or replace function public.derive_weakness_from_item()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_student uuid;
begin
  select a.student_id into v_student
    from public.attempts a where a.id = new.attempt_id;

  if v_student is not null then
    perform public.recompute_weaknesses(v_student, new.micro_skill_id);
  end if;

  return new;
end;
$$;

create trigger attempt_items_derive_weakness
  after insert on public.attempt_items
  for each row execute function public.derive_weakness_from_item();

-- ── RLS ───────────────────────────────────────────────────────────────────
alter table public.attempts      enable row level security;
alter table public.attempt_items enable row level security;
alter table public.weaknesses    enable row level security;

-- Reachable when the row is your own, or belongs to a student in a class you
-- teach, or you are an admin.
create or replace function public.may_read_student(p_student_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
      from public.students s
     where s.id = p_student_id
       and s.school_id = public.jwt_school_id()
       and (
         s.profile_id = auth.uid()
         or public.jwt_user_role() = 'admin'
         or (s.class_id is not null and public.teaches_class(s.class_id))
       )
  );
$$;

create policy attempts_select on public.attempts
  for select to authenticated using (public.may_read_student(student_id));

create policy attempts_insert on public.attempts
  for insert to authenticated
  with check (
    school_id = public.jwt_school_id()
    and exists (
      select 1 from public.students s
       where s.id = attempts.student_id and s.profile_id = auth.uid()
    )
  );

create policy attempt_items_select on public.attempt_items
  for select to authenticated
  using (
    exists (
      select 1 from public.attempts a
       where a.id = attempt_items.attempt_id
         and public.may_read_student(a.student_id)
    )
  );

create policy attempt_items_insert on public.attempt_items
  for insert to authenticated
  with check (
    exists (
      select 1
        from public.attempts a
        join public.students s on s.id = a.student_id
       where a.id = attempt_items.attempt_id
         and s.profile_id = auth.uid()
    )
  );

create policy weaknesses_select on public.weaknesses
  for select to authenticated using (public.may_read_student(student_id));
