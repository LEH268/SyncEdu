-- Teaching review: a teacher's own diagnostic over their class results, plus
-- the re-teach deck generated from it.
--
-- The design spec (section 11) rules out *teacher performance* analytics:
-- there is no longitudinal per-teacher data to derive one from, and a figure
-- that cannot answer questions about its own derivation has no business in
-- an appraisal. This table stays on the other side of that line by design:
--
--   * it is scoped to one (class, chapter), never rolled up per teacher;
--   * every number in `signals` was computed in Dart from the same "per
--     student, then count" evidence the resource recommendation fires on, and
--     is stored verbatim beside the prose written about it, so a finding can
--     always be traced back to the rows and the threshold that produced it;
--   * it is readable by its own author and by nobody else -- not by admins.
--     A tool a teacher uses to find their own weak spots stops being that the
--     moment it doubles as a record someone else can appraise them with.
--
-- Tier 1, append-only: each generation is a new row keyed by a client-supplied
-- uuid, so the outbox push is idempotent and a re-send can never overwrite an
-- earlier review.

create table public.teaching_insights (
  id            uuid primary key,
  school_id     uuid not null references public.schools (id) on delete cascade,
  teacher_id    uuid not null references public.profiles (id) on delete cascade,
  class_id      uuid not null references public.classes (id) on delete cascade,
  chapter_id    uuid not null references public.chapters (id) on delete cascade,
  -- The Dart-computed findings this review fired on: one entry per flagged
  -- micro-skill, carrying its proportion, counts, cross-class comparison and
  -- the distractors students chose. Stored as evidence, never re-derived here
  -- and never used to drive a query.
  signals       jsonb not null default '[]'::jsonb,
  -- Prose. `summary` falls back to the Dart-rendered rule headline whenever
  -- the model call fails, which is what `source` records.
  summary       text not null default '',
  actions       jsonb not null default '[]'::jsonb,
  -- The re-teach slide deck: { title, slides: [{ title, bullets, notes,
  -- micro_skill }] }. Handed to the client verbatim; the console renders it
  -- and writes the .pptx locally.
  deck          jsonb not null default '{}'::jsonb,
  source        text not null default 'rule' check (source in ('ai', 'rule')),
  model_version text,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  deleted_at    timestamptz
);
create index teaching_insights_watermark_idx
  on public.teaching_insights (school_id, updated_at);
-- The tab's own read: the latest review for one (class, chapter).
create index teaching_insights_lookup_idx
  on public.teaching_insights (teacher_id, class_id, chapter_id, created_at desc);
create trigger teaching_insights_set_updated_at
  before update on public.teaching_insights
  for each row execute function public.set_updated_at();

alter table public.teaching_insights enable row level security;

-- Author-only, in both directions. `teaches_class` is checked on insert as
-- well as authorship: a teacher must not be able to file a review against a
-- class they do not take, even under their own name.
create policy teaching_insights_select on public.teaching_insights
  for select to authenticated
  using (
    school_id = public.jwt_school_id()
    and teacher_id = auth.uid()
  );

create policy teaching_insights_insert on public.teaching_insights
  for insert to authenticated
  with check (
    school_id = public.jwt_school_id()
    and teacher_id = auth.uid()
    and public.jwt_user_role() = 'teacher'
    and public.teaches_class(class_id)
  );

-- No update and no delete policy: append-only, like every other tier-1 table.
grant select, insert on public.teaching_insights to authenticated;
