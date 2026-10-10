# Tautan Promosi Tryout Cognera

1. Jalankan `supabase/migrations/20261010_tryout_campaigns.sql` di Supabase SQL Editor.
2. Deploy `admin.html` dan `app.html` bersama aset proyek seperti biasa.
3. Buka Admin → **Promosi Tryout**. Pilih tryout, atur link profil/postingan/komentar/panduan Story, lalu simpan. Tiap tryout memiliki tautan sendiri.
4. Pengguna akan melihat tautan kampanye ketika membuka syarat tryout gratis. Empat screenshot wajib diunggah; setelah berhasil disimpan, tryout langsung dimulai tanpa approval admin.
5. Bukti tersimpan untuk pemeriksaan belakangan. Tindakan blokir akun atau pembatalan hasil setelah bukti palsu diketahui tetap merupakan keputusan admin; fitur unggah ini tidak otomatis memverifikasi keaslian bukti.

Catatan keamanan: kebijakan RLS membolehkan publik membaca kampanye aktif dan membatasi perubahan pada user yang tercatat di `public.admins`. Tidak ada service-role key di frontend.


## Bukti promosi versi 3 screenshot
Jalankan `TRYOUT_SOCIAL_PROOF_USERNAME_3_SCREENSHOTS.sql` di Supabase SQL Editor untuk menambahkan kolom `instagram_username`. Formulir tryout gratis meminta username Instagram pengguna dan tiga bukti terpisah: Follow, Like, serta komentar yang menyebut minimal tiga teman. Username akun resmi dan tautan postingan tampil sebagai tautan teks yang dapat diklik. Hanya paket UTBK SNBT yang dapat dibeli saat ini; TKA SMA, Mandiri PTN, dan Kedinasan ditampilkan sebagai Segera Hadir.
