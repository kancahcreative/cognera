# Perbaikan tombol ulang tryout

Penyebab yang ditemukan: pemeriksaan batas percobaan gratis dijalankan sebelum akses langganan dipertimbangkan. Akibatnya, pengguna yang sudah memiliki entitlement aktif masih melihat tombol Upgrade setelah kuota percobaan gratis habis.

Perubahan di app.html:
- Kartu daftar tryout hanya menampilkan tombol Upgrade karena kuota habis jika pengguna tidak memiliki entitlement yang cocok dan aktif.
- Halaman detail tryout memakai kondisi yang sama.
- Akun dengan entitlement aktif untuk jalur tryout dapat mengerjakan ulang tanpa diarahkan ke halaman paket hanya karena hitungan percobaan gratis.

Catatan: perbaikan ini memperbaiki logika antarmuka. Bila saat menekan Mulai masih ditolak, periksa handler start-to dan kebijakan database/RLS atau fungsi server yang menyimpan attempt. Uji langsung dengan akun Premium sebelum rilis.
