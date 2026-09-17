-- The knowledge layer: what a chapter contains, the closed micro-skill
-- vocabulary it is described in, and the shared question pool drawn from it.

create table public.materials (
  id                uuid primary key,
  school_id         uuid not null references public.schools (id) on delete cascade,
  chapter_id        uuid not null references public.chapters (id) on delete cascade,
  uploaded_by       uuid not null references public.profiles (id) on delete cascade,
  storage_path      text not null,
  mime_type         text not null check (mime_type in (
                      'application/pdf', 'image/png', 'image/jpeg', 'image/webp')),
  original_filename text not null,
  -- The resumable pipeline's ladder. Stage failures retry from where they
  -- stopped rather than re-running the expensive file read.
  ingestion_status  text not null default 'pending' check (ingestion_status in (
                      'pending', 'pack_ready', 'pool_ready', 'ready', 'failed')),
  ingestion_error   text,
  attempts          integer not null default 0,
  ingested_at       timestamptz,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  deleted_at        timestamptz
);
create index materials_watermark_idx on public.materials (school_id, updated_at);
create index materials_pending_idx on public.materials (ingestion_status)
  where ingestion_status not in ('ready', 'failed');
create trigger materials_set_updated_at before update on public.materials
  for each row execute function public.set_updated_at();

create table public.knowledge_packs (
  id                 uuid primary key,
  school_id          uuid not null references public.schools (id) on delete cascade,
  chapter_id         uuid not null references public.chapters (id) on delete cascade,
  material_id        uuid not null references public.materials (id) on delete cascade,
  concepts           jsonb not null default '[]'::jsonb,
  definitions        jsonb not null default '[]'::jsonb,
  formulas           jsonb not null default '[]'::jsonb,
  worked_examples    jsonb not null default '[]'::jsonb,
  difficulty_markers jsonb not null default '[]'::jsonb,
  source_refs        jsonb not null default '[]'::jsonb,
  model_version      text not null,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now(),
  deleted_at         timestamptz,
  unique (material_id)
);
create index knowledge_packs_watermark_idx on public.knowledge_packs (school_id, updated_at);
create trigger knowledge_packs_set_updated_at before update on public.knowledge_packs
  for each row execute function public.set_updated_at();

-- ── micro-skills: the analytic spine ──────────────────────────────────────
create table public.micro_skills (
  id          uuid primary key,
  school_id   uuid not null references public.schools (id) on delete cascade,
  chapter_id  uuid not null references public.chapters (id) on delete cascade,
  slug        text not null,
  label       text not null,
  description text,
  ordinal     integer not null,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  deleted_at  timestamptz,
  unique (chapter_id, slug),
  -- Redundant on its own, but required as the target of the composite foreign
  -- key on questions. This one line is what makes cross-chapter citation
  -- impossible rather than merely discouraged.
  unique (id, chapter_id)
);
create index micro_skills_watermark_idx on public.micro_skills (school_id, updated_at);
create trigger micro_skills_set_updated_at before update on public.micro_skills
  for each row execute function public.set_updated_at();

-- The closed set. Once a chapter is stamped, no further slug may be inserted.
create or replace function public.refuse_when_micro_skills_locked()
returns trigger
language plpgsql
as $$
declare
  v_locked timestamptz;
begin
  select micro_skills_locked_at into v_locked
    from public.chapters where id = new.chapter_id;

  if v_locked is not null then
    raise exception
      'chapter % has a closed micro-skill set (locked at %); map onto an existing slug instead',
      new.chapter_id, v_locked
      using errcode = '23514';
  end if;

  return new;
end;
$$;

create trigger lock_micro_skills
  before insert on public.micro_skills
  for each row execute function public.refuse_when_micro_skills_locked();

create table public.micro_skill_explanations (
  id             uuid primary key,
  school_id      uuid not null references public.schools (id) on delete cascade,
  micro_skill_id uuid not null references public.micro_skills (id) on delete cascade,
  body           text not null,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  deleted_at     timestamptz,
  unique (micro_skill_id)
);
create index micro_skill_explanations_watermark_idx
  on public.micro_skill_explanations (school_id, updated_at);
create trigger micro_skill_explanations_set_updated_at
  before update on public.micro_skill_explanations
  for each row execute function public.set_updated_at();

-- ── the question pool ─────────────────────────────────────────────────────
create table public.questions (
  id              uuid primary key,
  school_id       uuid not null references public.schools (id) on delete cascade,
  chapter_id      uuid not null references public.chapters (id) on delete cascade,
  micro_skill_id  uuid not null,
  difficulty      integer not null check (difficulty between 1 and 3),
  stem            text not null,
  options         jsonb not null,
  correct_index   integer not null,
  rationale       text,
  provenance      text not null default 'pool'
                    check (provenance in ('pool', 'personalised')),
  for_student_id  uuid references public.students (id) on delete cascade,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  deleted_at      timestamptz,

  -- THE constraint. A question can only cite a micro-skill that belongs to
  -- the same chapter; Postgres refuses anything else.
  foreign key (micro_skill_id, chapter_id)
    references public.micro_skills (id, chapter_id) on delete cascade,

  constraint questions_options_shape
    check (jsonb_typeof(options) = 'array' and jsonb_array_length(options) between 2 and 6),
  constraint questions_correct_index_in_range
    check (correct_index >= 0 and correct_index < jsonb_array_length(options)),
  constraint questions_personalised_has_student
    check (
      (provenance = 'pool' and for_student_id is null)
      or (provenance = 'personalised' and for_student_id is not null)
    )
);
create index questions_watermark_idx on public.questions (school_id, updated_at);
create index questions_chapter_band_idx on public.questions (chapter_id, difficulty);
create index questions_skill_idx on public.questions (micro_skill_id);
create index questions_personalised_idx on public.questions (for_student_id)
  where for_student_id is not null;
create trigger questions_set_updated_at before update on public.questions
  for each row execute function public.set_updated_at();

-- ── RLS ───────────────────────────────────────────────────────────────────
alter table public.materials                enable row level security;
alter table public.knowledge_packs          enable row level security;
alter table public.micro_skills             enable row level security;
alter table public.micro_skill_explanations enable row level security;
alter table public.questions                enable row level security;

-- Students never read raw material: the Knowledge Pack is what they consume.
-- This is what keeps the offline payload near 100 KB per chapter.
create policy materials_select on public.materials
  for select to authenticated
  using (
    school_id = public.jwt_school_id()
    and public.jwt_user_role() in ('admin', 'teacher')
  );

create policy materials_write on public.materials
  for all to authenticated
  using (
    school_id = public.jwt_school_id()
    and public.jwt_user_role() in ('admin', 'teacher')
  )
  with check (
    school_id = public.jwt_school_id()
    and public.jwt_user_role() in ('admin', 'teacher')
  );

create policy knowledge_packs_select on public.knowledge_packs
  for select to authenticated using (school_id = public.jwt_school_id());

create policy micro_skills_select on public.micro_skills
  for select to authenticated using (school_id = public.jwt_school_id());

create policy micro_skill_explanations_select on public.micro_skill_explanations
  for select to authenticated using (school_id = public.jwt_school_id());

-- A student may read the shared pool, plus questions generated for them --
-- never another student's personalised items.
create policy questions_select on public.questions
  for select to authenticated
  using (
    school_id = public.jwt_school_id()
    and (
      provenance = 'pool'
      or public.jwt_user_role() in ('admin', 'teacher')
      or exists (
        select 1 from public.students s
         where s.id = questions.for_student_id and s.profile_id = auth.uid()
      )
    )
  );

insert into public.sync_writable_fields (table_name, field, tier) values
  ('materials', 'ingestion_status', 2);
