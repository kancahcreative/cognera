-- Store the Instagram username submitted with the three required screenshots.
-- Safe to run even if the column already exists.
alter table public.tryout_social_proofs
  add column if not exists instagram_username text;
