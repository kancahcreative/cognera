# Cognera — checkout QRIS statis (verifikasi manual)

Versi ini menghapus ketergantungan checkout pada pembuatan tagihan Pakasir. Pengguna membayar menggunakan QRIS statis, memasukkan nominal pesanan secara manual, mengunggah bukti pembayaran, lalu mengirim konfirmasi. Admin memeriksa mutasi transaksi dan menyetujui/menolak dari menu Admin > Transaksi.

## Isi perubahan
- `app.html`: pilihan pembayaran hanya QRIS; halaman bayar menampilkan QRIS statis `assets/qris-kancah.jpeg`, nominal pesanan, instruksi memasukkan nominal, dan tombol `Saya Sudah Bayar`.
- `supabase/functions/create-payment`: membuat order dari harga server tanpa memanggil gateway.
- `supabase/functions/submit-payment-confirmation`: mengubah order milik pengguna dari `pending` menjadi `waiting_verification`.
- `supabase/functions/verify-manual-payment`: hanya admin di tabel `admins` yang dapat menyetujui/menolak. Persetujuan memanggil RPC `fulfill_order` agar aktivasi tetap dilakukan di backend.
- `admin.html`: daftar transaksi, tautan bukti pembayaran privat, serta tombol Setujui/Tolak untuk order QRIS yang menunggu verifikasi.

## Langkah pemasangan
1. Cadangkan repository dan database sebelum mengganti file.
2. Pastikan `assets/qris-kancah.jpeg` benar-benar QRIS merchant yang aktif yang masih aktif. QRIS ini statis, sehingga pembeli wajib memasukkan nominal sendiri.
3. Jalankan migration `supabase/migrations/20261010_manual_qris_checkout.sql` di Supabase SQL Editor (migration menambahkan kolom bukti pembayaran, bucket Storage privat, serta kebijakan akses upload dan admin).
4. Deploy Edge Functions:

   ```bash
   supabase functions deploy create-payment
   supabase functions deploy submit-payment-confirmation
   supabase functions deploy verify-manual-payment
   ```

5. Pastikan tabel `admins` berisi akun admin yang akan memverifikasi transaksi.
6. **Pastikan kebijakan Storage untuk bucket `payment-proofs` terpasang sebelum menguji unggahan.** Pengguna hanya boleh mengunggah ke folder miliknya; admin yang terdaftar dapat membuka bukti melalui signed URL sementara.\n7. **Sebelum menerima uang sungguhan, pastikan RPC `fulfill_order(p_order, p_txn)` memang tersedia dan aman/idempotent.** RPC tersebut harus memperbarui order menjadi `paid` dan membuat/ memperpanjang entitlement berdasarkan `package_id`, `user_id`, dan `months`. Jika RPC tidak ada atau skemanya berbeda, persetujuan admin akan gagal dengan aman dan tidak mengaktifkan Premium.
7. Deploy file frontend ke hosting. Uji dengan pesanan bernilai kecil: buat order, bayar, konfirmasi, periksa transaksi di HP merchant, setujui di admin, lalu pastikan `orders.status = paid` dan entitlement muncul.

## Catatan operasional dan keamanan
- Jangan menyetujui pembayaran hanya dari screenshot. Cocokkan mutasi merchant, nominal, waktu, dan order yang sedang menunggu.
- Karena QRIS statis tidak mengandung ID order atau nominal dinamis, dua pembelian bernominal sama bisa sulit dibedakan. Periksa waktu dan riwayat transaksi; jika ragu, jangan setujui sebelum klarifikasi.
- Tombol “Saya Sudah Bayar” hanya mengubah status ke `waiting_verification`; tidak mengaktifkan Premium.
- Pesanan berlaku 24 jam pada tahap awal. Pengguna yang telanjur membayar setelah kedaluwarsa harus menghubungi admin, jangan membuat pembayaran kedua sebelum transaksi pertama dicek.
- Edge Function `check-payment` dan webhook Pakasir lama tidak lagi dipakai oleh alur checkout QRIS manual. Jangan menghapusnya sampai dipastikan tidak dipakai alur lain.
- Kode masih memakai tabel/kolom existing Cognera (`packages`, `package_prices`, `payment_fees`, `orders`, `admins`, `entitlements`) dan RPC `check_partner_code`. Tes staging dulu karena skema live tidak dapat diverifikasi dari arsip kode saja.


## Catatan revisi UI
- Durasi paket di popup diurutkan dari harga termurah ke termahal dan default memilih durasi 1 bulan.
- Metode pembayaran menampilkan beberapa opsi lebih dulu; opsi lain dibuka melalui tombol **Lihat selengkapnya**. QRIS tetap satu-satunya metode aktif.
- Setelah bukti dikirim, pengguna mendapat estimasi verifikasi maksimal 1–2 jam dan tombol WhatsApp Contact Cognera di https://wa.me/628924687866 jika melewati waktu tersebut.
- Form pendaftaran juga mencoba menyimpan nama dan username ke `public.profiles`; jalankan migrasi terbaru sebelum deploy.
