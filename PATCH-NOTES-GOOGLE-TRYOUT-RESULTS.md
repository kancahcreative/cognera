# Perbaikan Login Google dan Hasil Tryout Admin

## Login Google
- Alur OAuth di `app.html` diubah agar Supabase mengembalikan URL OAuth (`skipBrowserRedirect: true`) lalu browser diarahkan satu kali ke URL tersebut.
- Parameter `prompt=select_account` tetap dikirim agar Google meminta pengguna memilih akun.
- `redirectTo` tetap mengarah kembali ke halaman aplikasi saat ini setelah autentikasi.

Jika halaman tetap langsung kembali ke `app.html` tanpa pemilih akun, periksa konfigurasi provider (ini tidak dapat diperbaiki hanya dari HTML):
1. Supabase Dashboard → Authentication → URL Configuration: masukkan URL aplikasi yang benar ke **Redirect URLs** (misalnya `https://cognera.kancah.com/app.html` jika itu URL produksi).
2. Supabase Dashboard → Authentication → Sign In / Providers → Google: pastikan Google provider aktif dan Client ID/Secret sesuai.
3. Google Cloud Console → OAuth Client Web → **Authorized redirect URIs** harus menggunakan callback Supabase: `https://azjseobcambbbllqlqxx.supabase.co/auth/v1/callback`. Jangan menggunakan `app.html` sebagai Google callback URI; `app.html` adalah tujuan setelah Supabase menyelesaikan OAuth.

## Hasil Tryout Admin
- Menambahkan menu **Hasil Tryout** yang membaca percobaan dari `user_data.data.attempts`.
- Tabel mencakup pengguna, email/username jika tersedia, sekolah/kelas, nama tryout, jalur, urutan percobaan, nilai, benar/salah/kosong, jumlah soal, durasi, dan waktu selesai.
- Detail per percobaan menampilkan rekap nilai per subtes serta ID soal dan jawaban yang tersimpan.
- Pencarian, pengurutan nilai, refresh, dan ekspor CSV disediakan.
- Data historis yang hanya tersimpan di perangkat pengguna dan belum tersinkron ke `user_data` tidak dapat muncul di admin. Pastikan kebijakan RLS Supabase mengizinkan akun admin membaca `user_data`, `profiles`, dan `tryouts`.
