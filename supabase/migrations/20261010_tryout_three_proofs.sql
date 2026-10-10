-- Store the three required screenshots on the existing per-user/per-tryout proof record.
ALTER TABLE public.tryout_social_proofs
  ADD COLUMN IF NOT EXISTS follow_path text,
  ADD COLUMN IF NOT EXISTS like_path text,
  ADD COLUMN IF NOT EXISTS mention_path text;

-- Backfill legacy single-proof rows as the Follow screenshot for compatibility.
UPDATE public.tryout_social_proofs
SET follow_path = COALESCE(follow_path, storage_path)
WHERE follow_path IS NULL;
