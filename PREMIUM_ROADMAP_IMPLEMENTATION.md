# Kebijakan Free dan Premium Cognera

## Free
- Latihan gratis dan tryout gratis yang ditandai sebagai gratis.
- Leaderboard menampilkan 10 teratas; posisi pribadi tetap ditampilkan (contoh: peringkat #163), tetapi daftar di bawah 10 besar tidak ditampilkan.
- Nera: 3 kesempatan per akun pada implementasi client-side saat ini.

## Premium
- Semua tryout Premium dan pembahasan soal lengkap.
- Leaderboard lengkap.
- Nera dengan akses lebih luas (versi ini memakai aturan lokal, bukan LLM/API AI berbayar).
- Error Notebook, Retry Salah Saja, Personal Study Plan, Smart Flashcards, ekspor laporan PDF.
- Halaman Prediksi Kampus sudah dibuat sebagai kerangka; belum mengeluarkan rekomendasi kampus sampai dataset skor pembanding kampus/program studi yang terverifikasi disediakan.

## Batasan implementasi yang harus diperhatikan sebelum produksi
- Kuota Nera saat ini tersimpan di data aplikasi lokal/sinkronisasi user_data; ini bukan mekanisme anti-manipulasi yang kuat. Untuk enforce per akun, pindahkan validasi dan increment kuota ke fungsi server/database atomik.
- Peringkat pribadi Free dihitung dari profil XP dan query jumlah profil dengan XP lebih tinggi. Jika RLS Supabase membatasi hitungan publik, rank mungkin tidak dapat ditampilkan sampai policy/view aman disiapkan.
- Pembahasan premium perlu ditegakkan juga di backend/data API, bukan hanya menyembunyikan teks di UI. Jangan mengirim seluruh kunci/pembahasan ke akun Free bila ingin konten benar-benar terlindungi.
- Prediksi kampus tidak boleh menebak tanpa data pembanding yang valid.
