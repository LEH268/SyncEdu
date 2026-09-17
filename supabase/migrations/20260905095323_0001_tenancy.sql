-- Tenancy and identity: the three tables every later migration hangs off.
--
-- Universal column contract (spec section 5): every domain table carries a
-- client-supplied uuid primary key, school_id, created_at, updated_at
-- (trigger-maintained and indexed for watermark pulls) and a deleted_at
-- tombstone. A sync watermark cannot observe a hard delete, so application
-- code never hard-deletes; it stamps deleted_at.

create extension if not exists pgcrypto;

-- ── shared trigger ────────────────────────────────────────────────────────
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

-- ── schools ───────────────────────────────────────────────────────────────
-- The tenant root. It carries no school_id because it is the school.
create table public.schools (
  id                uuid primary key,
  name              text not null,
  education_level   text not null
                      check (education_level in ('primary', 'secondary', 'university')),
  content_language  text not null default 'en',
  max_offline_days  integer not null default 30 check (max_offline_days > 0),
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  deleted_at        timestamptz
);

create index schools_watermark_idx on public.schools (updated_at);

create trigger schools_set_updated_at
  before update on public.schools
  for each row execute function public.set_updated_at();

-- ── profiles ──────────────────────────────────────────────────────────────
-- One row per auth user. The access token hook reads school_id and role from
-- here on every token mint, so this table is the source of truth for both.
create table public.profiles (
  id          uuid primary key references auth.users (id) on delete cascade,
  school_id   uuid not null references public.schools (id) on delete cascade,
  role        text not null check (role in ('student', 'teacher', 'admin')),
  full_name   text not null,
  email       text not null,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  deleted_at  timestamptz
);

create index profiles_watermark_idx on public.profiles (school_id, updated_at);
create index profiles_school_role_idx on public.profiles (school_id, role);

create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

-- ── students ──────────────────────────────────────────────────────────────
-- class_id is deliberately absent. public.classes arrives with the academic
-- structure migration; adding the column then keeps this migration honest
-- about what it can actually reference.
--
-- version supports the tier-3 compare-and-set path in the sync layer.
create table public.students (
  id                          uuid primary key,
  school_id                   uuid not null references public.schools (id) on delete cascade,
  profile_id                  uuid not null unique references public.profiles (id) on delete cascade,
  special_needs               text[] not null default '{}',
  special_needs_note          text,
  pre_admission_completed_at  timestamptz,
  version                     integer not null default 1,
  created_at                  timestamptz not null default now(),
  updated_at                  timestamptz not null default now(),
  deleted_at                  timestamptz
);

create index students_watermark_idx on public.students (school_id, updated_at);

create trigger students_set_updated_at
  before update on public.students
  for each row execute function public.set_updated_at();
