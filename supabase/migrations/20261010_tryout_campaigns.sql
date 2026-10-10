-- Cognera: per-tryout Instagram campaign links. Admins can edit links in admin.html.
create table if not exists public.tryout_campaigns (
  id uuid primary key default gen_random_uuid(),
  tryout_id text not null unique,
  instagram_handle text not null default '@cognera.id',
  profile_url text not null default 'https://www.instagram.com/cognera.id/',
  post_url text,
  comment_url text,
  story_guide_url text,
  active boolean not null default true,
  updated_at timestamptz not null default now(),
  updated_by uuid references auth.users(id)
);
alter table public.tryout_campaigns enable row level security;
drop policy if exists "Public can read active tryout campaigns" on public.tryout_campaigns;
create policy "Public can read active tryout campaigns" on public.tryout_campaigns for select to anon, authenticated using (active = true);
drop policy if exists "Admins manage tryout campaigns" on public.tryout_campaigns;
create policy "Admins manage tryout campaigns" on public.tryout_campaigns for all to authenticated
using (exists (select 1 from public.admins a where a.user_id = auth.uid()))
with check (exists (select 1 from public.admins a where a.user_id = auth.uid()));
create index if not exists tryout_campaigns_active_idx on public.tryout_campaigns(active);
