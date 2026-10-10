# Cognera — timeline tryout, bukti promosi, dan paket Mandiri

## Perubahan UI dan alur
- Paket tryout Mandiri universitas dipindahkan dari paket yang dapat dibeli menjadi kartu **Segera hadir**, bersama informasi paket SKD Kedinasan.
- Tryout mengambil `open_at` dan `close_at` dari tabel `tryouts`; tampilan menampilkan status jadwal buka/tutup. Isi kedua kolom tersebut melalui Supabase untuk menentukan tanggal dan jam.
- Sebelum memulai tryout gratis, pengguna login wajib menyelesaikan syarat promosi (follow Instagram Cognera, like postingan yang ditentukan, mention 3 teman, share story) dan mengunggah screenshot. Setelah upload berhasil, tryout langsung dimulai.
- Ada pengecekan tabel `tryout_user_blocks` sebelum memulai/mengunggah bukti.

## Wajib dilakukan di Supabase
1. Jalankan `supabase/migrations/20261010_tryout_timeline_social_proof.sql` di SQL Editor.
2. Pastikan `tryouts.open_at` dan `tryouts.close_at` sudah tersedia (versi aplikasi menggunakannya saat ini). Atur nilai timestamp dengan zona waktu yang benar.
3. Untuk memblokir pengguna yang terbukti curang, admin perlu meninjau bukti lalu menambahkan baris ke `tryout_user_blocks` melalui panel admin/server-side. Jangan izinkan browser biasa membuat blokir sendiri. Menghapus blokir dilakukan admin dengan `active=false` atau mengisi `lifted_at` dan menyesuaikan pengecekan.
4. Bukti gambar tersimpan di bucket privat `tryout-proofs`. Kebijakan RLS mencegah pengguna melihat file milik orang lain.
5. Jangan gunakan screenshot sebagai satu-satunya bukti pasti keaslian; pemeriksaan manual/admin diperlukan. Saat ini unggah bukti langsung membuka tryout, sedangkan peninjauan dan blokir adalah tindakan moderasi lanjutan.

## Catatan
- Fitur ini adalah lapisan antarmuka + skema database awal. Uji di staging terlebih dahulu dan pastikan kebijakan RLS tidak bertabrakan dengan kebijakan proyek yang sudah ada.
- Akun tamu tidak bisa mengikuti tryout gratis karena bukti harus terikat ke akun login.
