# Patch penyimpanan hasil tryout dan Google OAuth

## Perubahan frontend
- `app.html`: sinkronisasi `user_data` sekarang membaca data server, menggabungkan `attempts` berdasarkan ID, menulis ke Supabase, lalu membaca ulang untuk memverifikasi hasil benar-benar tersimpan.
- Kegagalan simpan menampilkan alasan yang lebih spesifik, bukan toast generik.
- Hasil tryout menyimpan `title` dan `jalur` agar panel admin tetap punya metadata meskipun tabel `tryouts` tidak mengembalikan data.
- Merge saat login tidak lagi membuang attempt lokal hanya karena data remote lama belum memiliki array `attempts`.
- `admin.html`: error query tabel sekarang dicatat di Console, bukan diam-diam dianggap data kosong.

## Penting: Google OAuth akun baru
Frontend tidak dapat memperbaiki kegagalan pembuatan user yang terjadi di sisi Supabase Auth sebelum callback kembali ke website. Jika akun Google yang belum pernah terdaftar masih gagal:
1. Supabase Dashboard → Authentication → Sign In / Providers → Google: pastikan Google provider aktif dan Client ID/Secret benar.
2. Authentication → Settings / General: pastikan pendaftaran pengguna baru diizinkan (`Allow new users to sign up`).
3. Database → SQL Editor: cek trigger/function pada `auth.users`, terutama trigger yang membuat row `profiles`. Jika trigger tersebut gagal insert (misalnya username unik bentrok atau kolom wajib tidak tersedia), Supabase mengembalikan `Database error saving new user`. Perbaiki trigger sesuai skema `profiles` yang benar; jangan menghapus trigger secara membabi buta.
4. Authentication → URL Configuration: masukkan URL produksi Cognera ke Site URL dan Redirect URLs (misalnya `https://cognera.kancah.com/*`).

## Pengujian
Selesaikan tryout dengan akun non-guest, lihat toast. Jika gagal, Console menampilkan penyebab read/write/verify `user_data`. Pastikan RLS `user_data` mengizinkan user terautentikasi SELECT/INSERT/UPDATE hanya untuk `user_id = auth.uid()`. Jangan menonaktifkan RLS atau memasukkan service-role key ke frontend.
