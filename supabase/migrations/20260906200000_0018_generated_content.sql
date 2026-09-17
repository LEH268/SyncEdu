-- Generated revision content: notes, flashcards and stories (spec §5, §8.4,
-- plan Tasks 1-2).
--
-- A further generation target over the same Knowledge Pack, exactly like the
-- question pool. Append-only (tier 1): every deck or story is keyed by its
-- client-supplied id and never mutated. `student_id` is nullable — a pool
-- deck belongs to a chapter and any student may open it; a personalised one
-- carries the student it was shaped for.

create table public.generated_content (
  id          uuid primary key,
  school_id   uuid not null references public.schools (id) on delete cascade,
  chapter_id  uuid not null references public.chapters (id) on delete cascade,
  student_id  uuid references public.students (id) on delete cascade,
  kind        text not null check (kind in ('notes', 'flashcards', 'story')),
  -- The whole deck / story / note set, shape depending on `kind`. Handed to
  -- the client verbatim; never used to drive a query.
  payload     jsonb not null default '{}'::jsonb,
  model_version text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  deleted_at  timestamptz
);
create index generated_content_watermark_idx
  on public.generated_content (school_id, updated_at);
create index generated_content_lookup_idx
  on public.generated_content (chapter_id, kind, student_id);
create trigger generated_content_set_updated_at
  before update on public.generated_content
  for each row execute function public.set_updated_at();

alter table public.generated_content enable row level security;

-- A student reads a chapter's shared content, plus anything generated for
-- them; a teacher or admin of the school reads it all. No one writes it from
-- a client — generate-content holds the service role and persists inside the
-- call that produces it.
create policy generated_content_select on public.generated_content
  for select to authenticated
  using (
    school_id = public.jwt_school_id()
    and (
      student_id is null
      or public.may_read_student(student_id)
    )
  );

grant select on public.generated_content to authenticated;
