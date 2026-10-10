# Perbaikan layout dan akses Premium

- Mengembalikan daftar benefit Premium secara lengkap pada kartu perbandingan.
- Memindahkan informasi paket aktif dan judul `Pilih paket belajar` ke atas kartu perbandingan.
- Memperkuat pencocokan jalur paket dengan alias UTBK/SNBT, Mandiri PTN, dan Kedinasan.
- Pengecekan akses juga membaca entitlement aktif yang sudah dimuat pada sesi aplikasi.

Catatan: perubahan frontend ini perlu diuji bersama Supabase. Jika entitlement aktif tidak ada di tabel `entitlements` untuk user_id yang sedang login, akses server/database tetap perlu diperbaiki.
