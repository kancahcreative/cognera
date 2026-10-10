# Tautan Promosi Tryout Cognera

1. Jalankan `supabase/migrations/20261010_tryout_campaigns.sql` di Supabase SQL Editor.
2. Deploy `admin.html` dan `app.html` bersama aset proyek seperti biasa.
3. Buka Admin → **Promosi Tryout**. Pilih tryout, atur link profil/postingan/komentar/panduan Story, lalu simpan. Tiap tryout memiliki tautan sendiri.
4. Pengguna akan melihat tautan kampanye ketika membuka syarat tryout gratis. Tiga screenshot wajib diunggah (Follow, Like postingan, dan komentar mention 3 teman); setelah berhasil disimpan, tryout langsung dimulai tanpa approval admin.
5. Bukti tersimpan untuk pemeriksaan belakangan. Tindakan blokir akun atau pembatalan hasil setelah bukti palsu diketahui tetap merupakan keputusan admin; fitur unggah ini tidak otomatis memverifikasi keaslian bukti.

Catatan keamanan: kebijakan RLS membolehkan publik membaca kampanye aktif dan membatasi perubahan pada user yang tercatat di `public.admins`. Tidak ada service-role key di frontend.
