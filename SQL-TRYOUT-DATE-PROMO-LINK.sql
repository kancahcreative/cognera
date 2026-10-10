-- Jalankan sekali di Supabase SQL Editor sebelum memakai field promosi per tryout.
ALTER TABLE public.tryouts
  ADD COLUMN IF NOT EXISTS promo_post_url text;

-- open_at dan close_at sudah dipakai oleh aplikasi untuk jadwal tryout.
-- Jika belum ada di database, buka komentar di bawah dan jalankan juga:
-- ALTER TABLE public.tryouts ADD COLUMN IF NOT EXISTS open_at timestamptz;
-- ALTER TABLE public.tryouts ADD COLUMN IF NOT EXISTS close_at timestamptz;
