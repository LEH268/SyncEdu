-- Private buckets. Object paths begin with the school id, and every policy
-- checks that prefix against the caller's claim, so tenancy holds in Storage
-- exactly as it does in Postgres.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('materials',   'materials',   false, 52428800,
   array['application/pdf', 'image/png', 'image/jpeg', 'image/webp']),
  ('exam-papers', 'exam-papers', false, 20971520,
   array['application/pdf', 'image/png', 'image/jpeg', 'image/webp'])
on conflict (id) do nothing;

-- The first path segment is the school id.
create or replace function public.storage_school_id(p_name text)
returns uuid
language sql
immutable
as $$
  select nullif(split_part(p_name, '/', 1), '')::uuid;
$$;

-- ── materials: staff only, own school only ────────────────────────────────
create policy materials_staff_read on storage.objects
  for select to authenticated
  using (
    bucket_id = 'materials'
    and public.storage_school_id(name) = public.jwt_school_id()
    and public.jwt_user_role() in ('admin', 'teacher')
  );

create policy materials_staff_write on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'materials'
    and public.storage_school_id(name) = public.jwt_school_id()
    and public.jwt_user_role() in ('admin', 'teacher')
  );

create policy materials_staff_delete on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'materials'
    and public.storage_school_id(name) = public.jwt_school_id()
    and public.jwt_user_role() in ('admin', 'teacher')
  );

-- ── exam papers: staff write; the student named in the path may read ──────
create policy exam_papers_staff_all on storage.objects
  for all to authenticated
  using (
    bucket_id = 'exam-papers'
    and public.storage_school_id(name) = public.jwt_school_id()
    and public.jwt_user_role() in ('admin', 'teacher')
  )
  with check (
    bucket_id = 'exam-papers'
    and public.storage_school_id(name) = public.jwt_school_id()
    and public.jwt_user_role() in ('admin', 'teacher')
  );

create policy exam_papers_own_read on storage.objects
  for select to authenticated
  using (
    bucket_id = 'exam-papers'
    and public.storage_school_id(name) = public.jwt_school_id()
    and exists (
      select 1 from public.students s
       where s.profile_id = auth.uid()
         and split_part(storage.objects.name, '/', 2) = s.id::text
    )
  );
