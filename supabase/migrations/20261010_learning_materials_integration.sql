-- Cognera: PDF learning materials and publication access
create table if not exists public.learning_materials (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text not null default '',
  category text not null default 'Umum',
  storage_path text not null,
  file_name text not null,
  file_size bigint not null default 0,
  mime_type text not null default 'application/pdf',
  published boolean not null default false,
  published_at timestamptz,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint learning_materials_pdf_mime check (mime_type = 'application/pdf')
);

alter table public.learning_materials add column if not exists description text not null default '';
alter table public.learning_materials add column if not exists category text not null default 'Umum';
alter table public.learning_materials add column if not exists storage_path text;
alter table public.learning_materials add column if not exists file_name text;
alter table public.learning_materials add column if not exists file_size bigint not null default 0;
alter table public.learning_materials add column if not exists mime_type text not null default 'application/pdf';
alter table public.learning_materials add column if not exists published boolean not null default false;
alter table public.learning_materials add column if not exists published_at timestamptz;
alter table public.learning_materials add column if not exists created_by uuid references auth.users(id) on delete set null;
alter table public.learning_materials add column if not exists created_at timestamptz not null default now();
alter table public.learning_materials add column if not exists updated_at timestamptz not null default now();

alter table public.learning_materials enable row level security;
drop policy if exists "Published learning materials are readable" on public.learning_materials;
create policy "Published learning materials are readable" on public.learning_materials for select to anon, authenticated using (published = true);
drop policy if exists "Admins manage learning materials" on public.learning_materials;
create policy "Admins manage learning materials" on public.learning_materials for all to authenticated using (
  exists (select 1 from public.admins a where a.user_id = auth.uid())
) with check (
  exists (select 1 from public.admins a where a.user_id = auth.uid())
);

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('learning-materials', 'learning-materials', false, 26214400, array['application/pdf'])
on conflict (id) do update set public = false, file_size_limit = 26214400, allowed_mime_types = array['application/pdf'];

drop policy if exists "Admins upload learning PDFs" on storage.objects;
create policy "Admins upload learning PDFs" on storage.objects for insert to authenticated with check (
  bucket_id = 'learning-materials' and exists (select 1 from public.admins a where a.user_id = auth.uid())
);
drop policy if exists "Admins update learning PDFs" on storage.objects;
create policy "Admins update learning PDFs" on storage.objects for update to authenticated using (
  bucket_id = 'learning-materials' and exists (select 1 from public.admins a where a.user_id = auth.uid())
) with check (bucket_id = 'learning-materials' and exists (select 1 from public.admins a where a.user_id = auth.uid()));
drop policy if exists "Admins delete learning PDFs" on storage.objects;
create policy "Admins delete learning PDFs" on storage.objects for delete to authenticated using (
  bucket_id = 'learning-materials' and exists (select 1 from public.admins a where a.user_id = auth.uid())
);
drop policy if exists "Admins and students read published learning PDFs" on storage.objects;
create policy "Admins and students read published learning PDFs" on storage.objects for select to anon, authenticated using (
  bucket_id = 'learning-materials' and (
    exists (select 1 from public.learning_materials lm where lm.storage_path = name and lm.published = true)
    or exists (select 1 from public.admins a where a.user_id = auth.uid())
  )
);
