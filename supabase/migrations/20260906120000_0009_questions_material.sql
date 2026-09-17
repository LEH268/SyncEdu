-- Ingestion is resumable, not transactional. stagePool regenerates a band at a
-- time; on a mid-stage retry it must be able to discard exactly the pool rows
-- this material produced and no others. A nullable material_id gives that scope
-- without touching existing rows or personalised questions.

-- `on delete cascade` is deliberate: deleting a material retires its derived
-- pool questions; personalised questions have material_id is null and survive.
alter table public.questions
  add column material_id uuid references public.materials (id) on delete cascade;

create index questions_material_idx on public.questions (material_id)
  where material_id is not null;
