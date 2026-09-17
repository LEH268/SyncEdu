-- Academic structure.
--
-- Two ownership rules from the spec drive the shape here:
--   * material belongs to a SUBJECT-chapter and is shared by every class
--     taking that subject, so a teacher uploads once;
--   * the schedule belongs to a CLASS-chapter and is independent per class,
--     so one class may be several chapters ahead of another.

create table public.subjects (
  id             uuid primary key,
  school_id      uuid not null references public.schools (id) on delete cascade,
  name           text not null,
  chapter_count  integer not null default 0 check (chapter_count >= 0),
  version        integer not null default 1,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  deleted_at     timestamptz
);
create index subjects_watermark_idx on public.subjects (school_id, updated_at);
create trigger subjects_set_updated_at before update on public.subjects
  for each row execute function public.set_updated_at();

create table public.chapters (
  id                      uuid primary key,
  school_id               uuid not null references public.schools (id) on delete cascade,
  subject_id              uuid not null references public.subjects (id) on delete cascade,
  ordinal                 integer not null check (ordinal > 0),
  title                   text not null,
  -- Stamped by the first ingestion. After this, the chapter's micro-skill
  -- vocabulary is closed: see migration 0006's lock trigger.
  micro_skills_locked_at  timestamptz,
  created_at              timestamptz not null default now(),
  updated_at              timestamptz not null default now(),
  deleted_at              timestamptz,
  unique (subject_id, ordinal),
  -- Composite target so questions can prove a micro-skill belongs to their
  -- own chapter without a second lookup.
  unique (id, subject_id)
);
create index chapters_watermark_idx on public.chapters (school_id, updated_at);
create trigger chapters_set_updated_at before update on public.chapters
  for each row execute function public.set_updated_at();

create table public.classes (
  id                    uuid primary key,
  school_id             uuid not null references public.schools (id) on delete cascade,
  name                  text not null,
  year_level            integer not null,
  -- Read by the placement engine. The reference collected this and never used
  -- it; that defect is not reproduced.
  target_learning_style text check (target_learning_style in ('V', 'A', 'R', 'K')),
  version               integer not null default 1,
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),
  deleted_at            timestamptz,
  unique (id, school_id)
);
create index classes_watermark_idx on public.classes (school_id, updated_at);
create trigger classes_set_updated_at before update on public.classes
  for each row execute function public.set_updated_at();

create table public.class_subjects (
  id          uuid primary key,
  school_id   uuid not null references public.schools (id) on delete cascade,
  class_id    uuid not null references public.classes (id) on delete cascade,
  subject_id  uuid not null references public.subjects (id) on delete cascade,
  teacher_id  uuid not null references public.profiles (id) on delete cascade,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  deleted_at  timestamptz,
  unique (class_id, subject_id)
);
create index class_subjects_watermark_idx on public.class_subjects (school_id, updated_at);
create index class_subjects_teacher_idx on public.class_subjects (teacher_id);
create trigger class_subjects_set_updated_at before update on public.class_subjects
  for each row execute function public.set_updated_at();

create table public.class_chapter_sched (
  id          uuid primary key,
  school_id   uuid not null references public.schools (id) on delete cascade,
  class_id    uuid not null references public.classes (id) on delete cascade,
  chapter_id  uuid not null references public.chapters (id) on delete cascade,
  taught_on   date,
  version     integer not null default 1,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  deleted_at  timestamptz,
  unique (class_id, chapter_id)
);
create index class_chapter_sched_watermark_idx
  on public.class_chapter_sched (school_id, updated_at);
create trigger class_chapter_sched_set_updated_at
  before update on public.class_chapter_sched
  for each row execute function public.set_updated_at();

-- ── students.class_id ─────────────────────────────────────────────────────
-- Deferred from migration 0001 because public.classes did not exist. The
-- composite reference is what stops a student being placed in another
-- school's class -- a plain FK to classes(id) would allow exactly that.
alter table public.students
  add column class_id uuid,
  add constraint students_class_same_school
    foreign key (class_id, school_id)
    references public.classes (id, school_id) on delete set null;

-- ── who teaches what ──────────────────────────────────────────────────────
create or replace function public.teaches_class(p_class_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
      from public.class_subjects cs
     where cs.class_id = p_class_id
       and cs.teacher_id = auth.uid()
       and cs.deleted_at is null
  );
$$;

-- ── RLS ───────────────────────────────────────────────────────────────────
alter table public.subjects            enable row level security;
alter table public.chapters            enable row level security;
alter table public.classes             enable row level security;
alter table public.class_subjects      enable row level security;
alter table public.class_chapter_sched enable row level security;

-- Subjects and chapters are school-wide reference data: a student needs to
-- see the chapters of subjects their class takes, and the simplest correct
-- rule is school-scoped read.
create policy subjects_select on public.subjects
  for select to authenticated using (school_id = public.jwt_school_id());

create policy chapters_select on public.chapters
  for select to authenticated using (school_id = public.jwt_school_id());

-- Classes: admins see the school, teachers see what they teach, students see
-- their own class.
create policy classes_select on public.classes
  for select to authenticated
  using (
    school_id = public.jwt_school_id()
    and (
      public.jwt_user_role() = 'admin'
      or public.teaches_class(id)
      or exists (
        select 1 from public.students s
         where s.class_id = classes.id and s.profile_id = auth.uid()
      )
    )
  );

create policy class_subjects_select on public.class_subjects
  for select to authenticated
  using (
    school_id = public.jwt_school_id()
    and (
      public.jwt_user_role() = 'admin'
      or teacher_id = auth.uid()
      or exists (
        select 1 from public.students s
         where s.class_id = class_subjects.class_id and s.profile_id = auth.uid()
      )
    )
  );

create policy class_chapter_sched_select on public.class_chapter_sched
  for select to authenticated
  using (
    school_id = public.jwt_school_id()
    and (
      public.jwt_user_role() = 'admin'
      or public.teaches_class(class_id)
      or exists (
        select 1 from public.students s
         where s.class_id = class_chapter_sched.class_id
           and s.profile_id = auth.uid()
      )
    )
  );

-- Teachers own the schedule for classes they teach.
create policy class_chapter_sched_write on public.class_chapter_sched
  for all to authenticated
  using (
    school_id = public.jwt_school_id()
    and (public.jwt_user_role() = 'admin' or public.teaches_class(class_id))
  )
  with check (
    school_id = public.jwt_school_id()
    and (public.jwt_user_role() = 'admin' or public.teaches_class(class_id))
  );

-- ── sync registration ─────────────────────────────────────────────────────
insert into public.sync_writable_fields (table_name, field, tier) values
  ('class_chapter_sched', 'taught_on',             2),
  ('subjects',            'chapter_count',         2),
  ('classes',             'target_learning_style', 3);
