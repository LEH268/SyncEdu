-- Year-End Reflection and the Class Fit Analyzer (spec §7.4).
--
-- A matched pair: the reflection supplies the 30% student component the
-- analyzer needs. Composition arithmetic is Dart (syncedu_core/fit_score);
-- only the observation scoring and the prose are Gemini's (analyse-fit).

-- ── campaigns ─────────────────────────────────────────────────────────────
-- An administrator opens a campaign; the student app raises the reflection on
-- next launch through the Phase 1 router gate.
create table public.reflection_campaigns (
  id             uuid primary key,
  school_id      uuid not null references public.schools (id) on delete cascade,
  academic_year  text not null,
  opened_at      timestamptz not null default now(),
  closed_at      timestamptz,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  deleted_at     timestamptz,
  unique (school_id, academic_year)
);
create index reflection_campaigns_watermark_idx
  on public.reflection_campaigns (school_id, updated_at);
create trigger reflection_campaigns_set_updated_at
  before update on public.reflection_campaigns
  for each row execute function public.set_updated_at();

create table public.year_end_reflections (
  id             uuid primary key,
  school_id      uuid not null references public.schools (id) on delete cascade,
  student_id     uuid not null references public.students (id) on delete cascade,
  campaign_id    uuid references public.reflection_campaigns (id) on delete set null,
  academic_year  text not null,
  responses      jsonb not null default '{}'::jsonb,
  -- The 0–100 self-report figure the fit score's 30% component reads. Null
  -- until the student answers; composeFitScore reweights around a null.
  student_pct    numeric(5, 2),
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  deleted_at     timestamptz,
  unique (student_id, academic_year)
);
create index year_end_reflections_watermark_idx
  on public.year_end_reflections (school_id, updated_at);
create trigger year_end_reflections_set_updated_at
  before update on public.year_end_reflections
  for each row execute function public.set_updated_at();

create table public.fit_analyses (
  id             uuid primary key,
  school_id      uuid not null references public.schools (id) on delete cascade,
  student_id     uuid not null references public.students (id) on delete cascade,
  academic_pct   numeric(5, 2),
  student_pct    numeric(5, 2),
  teacher_pct    numeric(5, 2),
  fit_score      numeric(5, 2),
  verdict        text check (verdict in
                   ('great_fit', 'acceptable', 'mismatch', 'strong_mismatch')),
  recommendation text,
  -- Which path produced `recommendation`: the model, or the Dart rule that
  -- stands in when the model call fails.
  source         text not null default 'rule' check (source in ('ai', 'rule')),
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  deleted_at     timestamptz
);
create index fit_analyses_watermark_idx
  on public.fit_analyses (school_id, updated_at);
create index fit_analyses_student_idx
  on public.fit_analyses (student_id, created_at desc);
create trigger fit_analyses_set_updated_at
  before update on public.fit_analyses
  for each row execute function public.set_updated_at();

-- ── placement ─────────────────────────────────────────────────────────────
-- The assignment is computed deterministically in Dart (placement_engine);
-- suggest-placement writes only the rationale. `status` is contended (tier 3):
-- an admin approves, overrides, or assigns manually.
create table public.placement_suggestions (
  id                uuid primary key,
  school_id         uuid not null references public.schools (id) on delete cascade,
  student_id        uuid not null references public.students (id) on delete cascade,
  suggested_class_id uuid,
  rationale         text not null default '',
  status            text not null default 'pending'
                      check (status in ('pending', 'approved', 'overridden', 'rejected')),
  version           integer not null default 1,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  deleted_at        timestamptz,
  constraint placement_suggestions_class_same_school
    foreign key (suggested_class_id, school_id)
    references public.classes (id, school_id) on delete set null
);
create index placement_suggestions_watermark_idx
  on public.placement_suggestions (school_id, updated_at);
create trigger placement_suggestions_set_updated_at
  before update on public.placement_suggestions
  for each row execute function public.set_updated_at();

-- ── RLS ───────────────────────────────────────────────────────────────────
alter table public.reflection_campaigns  enable row level security;
alter table public.year_end_reflections  enable row level security;
alter table public.fit_analyses          enable row level security;
alter table public.placement_suggestions enable row level security;

-- Campaigns are school-wide reference data; only an admin opens or closes one.
create policy reflection_campaigns_select on public.reflection_campaigns
  for select to authenticated using (school_id = public.jwt_school_id());
create policy reflection_campaigns_write on public.reflection_campaigns
  for all to authenticated
  using (school_id = public.jwt_school_id() and public.jwt_user_role() = 'admin')
  with check (school_id = public.jwt_school_id() and public.jwt_user_role() = 'admin');

create policy year_end_reflections_select on public.year_end_reflections
  for select to authenticated using (public.may_read_student(student_id));
create policy year_end_reflections_write on public.year_end_reflections
  for all to authenticated
  using (
    school_id = public.jwt_school_id()
    and exists (
      select 1 from public.students s
       where s.id = year_end_reflections.student_id and s.profile_id = auth.uid()
    )
  )
  with check (
    school_id = public.jwt_school_id()
    and exists (
      select 1 from public.students s
       where s.id = year_end_reflections.student_id and s.profile_id = auth.uid()
    )
  );

-- Fit analyses are staff-only: the student never sees the verdict.
create policy fit_analyses_select on public.fit_analyses
  for select to authenticated
  using (
    school_id = public.jwt_school_id()
    and (
      public.jwt_user_role() = 'admin'
      or exists (
        select 1 from public.students s
         where s.id = fit_analyses.student_id
           and s.class_id is not null
           and public.teaches_class(s.class_id)
      )
    )
  );

create policy placement_suggestions_select on public.placement_suggestions
  for select to authenticated
  using (
    school_id = public.jwt_school_id()
    and (
      public.jwt_user_role() = 'admin'
      or exists (
        select 1 from public.students s
         where s.id = placement_suggestions.student_id
           and s.class_id is not null
           and public.teaches_class(s.class_id)
      )
    )
  );
create policy placement_suggestions_write on public.placement_suggestions
  for all to authenticated
  using (school_id = public.jwt_school_id() and public.jwt_user_role() = 'admin')
  with check (school_id = public.jwt_school_id() and public.jwt_user_role() = 'admin');

-- ── grants ────────────────────────────────────────────────────────────────
grant select on public.reflection_campaigns to authenticated;
grant insert, update, delete on public.reflection_campaigns to authenticated;
grant select, insert, update on public.year_end_reflections to authenticated;
grant select on public.fit_analyses to authenticated;
grant select, insert, update on public.placement_suggestions to authenticated;

-- ── sync registration ─────────────────────────────────────────────────────
insert into public.sync_writable_fields (table_name, field, tier) values
  ('placement_suggestions', 'status', 3);
