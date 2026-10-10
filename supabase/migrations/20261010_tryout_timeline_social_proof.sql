-- Cognera: proof upload for free tryouts and user registration blocks.
-- Apply in Supabase SQL Editor before enabling the screenshot gate.
create table if not exists public.tryout_social_proofs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  tryout_id text not null,
  storage_path text not null,
  status text not null default 'submitted' check (status in ('submitted','approved','rejected','flagged')),
  review_note text,
  reviewed_by uuid references auth.users(id),
  reviewed_at timestamptz,
  created_at timestamptz not null default now(),
  unique (user_id, tryout_id)
);
create index if not exists tryout_social_proofs_user_tryout_idx on public.tryout_social_proofs(user_id, tryout_id);
alter table public.tryout_social_proofs enable row level security;
drop policy if exists "Users can view own tryout proof" on public.tryout_social_proofs;
create policy "Users can view own tryout proof" on public.tryout_social_proofs for select to authenticated using (auth.uid() = user_id);
drop policy if exists "Users can submit own tryout proof" on public.tryout_social_proofs;
create policy "Users can submit own tryout proof" on public.tryout_social_proofs for insert to authenticated with check (auth.uid() = user_id);
-- Admin review should use a server-side service-role action or a narrowly scoped admin policy.
-- Do not expose the service-role key in the browser.

create table if not exists public.tryout_user_blocks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  active boolean not null default true,
  reason text not null,
  evidence_path text,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  expires_at timestamptz,
  lifted_at timestamptz
  -- Multiple historical block records per user are allowed.
);
create index if not exists tryout_user_blocks_user_active_idx on public.tryout_user_blocks(user_id, active);
alter table public.tryout_user_blocks enable row level security;
-- Frontend may only check whether the current user has an active block.
drop policy if exists "Users can check own tryout block" on public.tryout_user_blocks;
create policy "Users can check own tryout block" on public.tryout_user_blocks for select to authenticated using (auth.uid() = user_id);

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('tryout-proofs','tryout-proofs',false,8388608,array['image/jpeg','image/png','image/webp'])
on conflict (id) do update set public=false, file_size_limit=8388608, allowed_mime_types=array['image/jpeg','image/png','image/webp'];
drop policy if exists "Users upload own tryout proof files" on storage.objects;
create policy "Users upload own tryout proof files" on storage.objects for insert to authenticated with check (bucket_id='tryout-proofs' and (storage.foldername(name))[1]=auth.uid()::text);
drop policy if exists "Users view own tryout proof files" on storage.objects;
create policy "Users view own tryout proof files" on storage.objects for select to authenticated using (bucket_id='tryout-proofs' and (storage.foldername(name))[1]=auth.uid()::text);
