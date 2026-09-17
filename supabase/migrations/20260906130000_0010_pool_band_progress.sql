alter table public.materials
  add column pool_bands_done integer not null default 0
    check (pool_bands_done between 0 and 3);
