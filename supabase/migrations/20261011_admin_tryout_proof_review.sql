-- Cognera Admin: izin admin untuk memeriksa 3 screenshot bukti syarat tryout,
-- memperbarui status review, melihat file privat, dan memblokir akses tryout akun.
-- Jalankan di Supabase SQL Editor setelah migration tryout_social_proofs/three_proofs.

ALTER TABLE public.tryout_social_proofs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tryout_user_blocks ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins read tryout social proofs" ON public.tryout_social_proofs;
CREATE POLICY "Admins read tryout social proofs"
ON public.tryout_social_proofs FOR SELECT TO authenticated
USING (EXISTS (SELECT 1 FROM public.admins a WHERE a.user_id = auth.uid()));

DROP POLICY IF EXISTS "Admins review tryout social proofs" ON public.tryout_social_proofs;
CREATE POLICY "Admins review tryout social proofs"
ON public.tryout_social_proofs FOR UPDATE TO authenticated
USING (EXISTS (SELECT 1 FROM public.admins a WHERE a.user_id = auth.uid()))
WITH CHECK (EXISTS (SELECT 1 FROM public.admins a WHERE a.user_id = auth.uid()));

DROP POLICY IF EXISTS "Admins read tryout user blocks" ON public.tryout_user_blocks;
CREATE POLICY "Admins read tryout user blocks"
ON public.tryout_user_blocks FOR SELECT TO authenticated
USING (EXISTS (SELECT 1 FROM public.admins a WHERE a.user_id = auth.uid()));

DROP POLICY IF EXISTS "Admins create tryout user blocks" ON public.tryout_user_blocks;
CREATE POLICY "Admins create tryout user blocks"
ON public.tryout_user_blocks FOR INSERT TO authenticated
WITH CHECK (EXISTS (SELECT 1 FROM public.admins a WHERE a.user_id = auth.uid()));

-- Bucket tetap private. Admin mendapatkan akses baca untuk signed URL sementara.
DROP POLICY IF EXISTS "Admins read tryout proof files" ON storage.objects;
CREATE POLICY "Admins read tryout proof files"
ON storage.objects FOR SELECT TO authenticated
USING (
  bucket_id = 'tryout-proofs'
  AND EXISTS (SELECT 1 FROM public.admins a WHERE a.user_id = auth.uid())
);

CREATE INDEX IF NOT EXISTS tryout_user_blocks_active_user_idx
ON public.tryout_user_blocks (user_id, active)
WHERE active = true;
