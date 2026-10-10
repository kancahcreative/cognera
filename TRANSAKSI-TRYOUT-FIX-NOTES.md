# Transaksi dan akses tryout — revisi

- Tombol **Transaksi saya** dipindahkan ke baris judul **Paket belajar** (bagian atas), sehingga tidak ada lagi section Rincian transaksi yang mengambil ruang di antara perbandingan paket dan daftar paket.
- Pengecekan akses tryout di frontend dibuat lebih toleran terhadap perbedaan format `package_id` (ID, slug, atau nama paket) dan memeriksa entitlement yang belum kedaluwarsa.

## Penting untuk mengatasi akun Premium yang masih terkunci
Ini memperbaiki pencocokan di frontend, tetapi tidak bisa mengubah data Supabase atau aturan RLS/server yang mungkin menolak akses. Jika akun tetap tidak bisa mulai tryout, periksa di Supabase bahwa entitlement akun tersebut berstatus aktif, `package_id` cocok dengan paket yang dibeli, `ends_at` belum lewat, dan fungsi/RLS yang mengambil entitlement mengembalikan baris tersebut. Pastikan pula tryout memang termasuk `covers` paket. Jangan meminta pengguna membayar ulang sebelum transaksi yang sudah lunas diperiksa.
