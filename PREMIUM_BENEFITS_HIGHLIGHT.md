# Pembaruan Benefit Premium Cognera

Kartu perbandingan Free dan Premium pada `app.html` kini menonjolkan benefit Premium berikut:

- **Tryout Premium dan pembahasan soal tryout** sebagai benefit utama yang di-highlight.
- Materi belajar Premium.
- Analisis kelemahan di setiap tryout berdasarkan data jawaban dan subtes.
- Prediksi kampus dan program studi berdasarkan skor tryout serta data pembanding yang tersedia.
- Analisis kecocokan program studi melalui asesmen kepribadian dan minat.
- Rencana belajar terarah berdasarkan target, waktu, dan kelemahan.
- Leaderboard lengkap, Nera AI dengan akses lebih luas, Error Notebook, Retry Salah Saja, Personal Study Plan, Smart Flashcards, dan ekspor laporan PDF.

## Aturan Free
- Latihan gratis dan tryout gratis yang tersedia.
- Leaderboard hanya menampilkan 10 teratas; posisi pengguna tetap dapat ditampilkan (contoh #163).
- Nera AI memiliki 3 kesempatan gratis.
- Materi, tryout Premium, pembahasan soal, dan analisis lanjutan dikunci untuk Premium.

## Catatan implementasi
Perubahan ini memperbarui tampilan perbandingan paket dan daftar benefit. Fitur analisis kepribadian memerlukan asesmen minat/kepribadian yang benar-benar diisi pengguna. Prediksi kampus memerlukan dataset program studi dan skor pembanding yang dapat dipertanggungjawabkan. Jangan menyebut hasil sebagai prediksi akurat sebelum dataset tersebut terhubung dan diuji. Proteksi akses materi/pembahasan harus ditegakkan di Supabase/RLS atau backend, bukan hanya disembunyikan di antarmuka.
