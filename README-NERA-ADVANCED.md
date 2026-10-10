# Nera — mode tanpa API berbayar

## Perubahan
- Nera tidak memanggil OpenAI, Gemini, atau provider AI eksternal.
- Tidak membutuhkan API key AI, token, maupun deploy Edge Function `nera-ai`.
- Balasan dibuat oleh fungsi JavaScript lokal berdasarkan aturan, data progres Cognera, dan pembahasan soal yang tersedia.
- Mode tutor, bedah soal, study coach, dan latihan interaktif tetap tersedia, tetapi kemampuan percakapan bebas terbatas.
- Aplikasi tidak berpura-pura bahwa balasan berbasis aturan adalah keluaran model generatif.

## Cara menggunakan
1. Ganti `app.html` dengan versi ini di repositori Cognera.
2. Tidak perlu mengatur `OPENAI_API_KEY` atau `OPENAI_MODEL`.
3. Uji login Free/Premium, mode Nera, pembahasan soal, dan data progres sebelum rilis.

## Batasan penting
Versi ini adalah asisten belajar berbasis aturan (rule-based), bukan LLM. Jawabannya berasal dari kondisi JavaScript, statistik progres, soal, dan pembahasan yang sudah tersimpan. Ia tidak dapat menjawab semua pertanyaan bebas seperti ChatGPT. Tidak ada biaya API AI, tetapi hosting dan layanan database yang dipakai aplikasi tetap dapat memiliki biaya sesuai paket layanan.

## Backend lama
Folder `supabase/functions/nera-ai` dari paket sebelumnya tidak diperlukan untuk versi ini dan sengaja dihilangkan dari ZIP tanpa API berbayar.
