# Cognera — checkout QRIS statis Kancah (verifikasi manual)

Versi ini menghapus ketergantungan checkout pada pembuatan tagihan Pakasir. Pengguna membayar menggunakan QRIS statis Kancah, memasukkan nominal pesanan secara manual, lalu mengirim konfirmasi. Admin memeriksa mutasi transaksi dan menyetujui/menolak dari menu Admin > Transaksi.

## Isi perubahan
- `app.html`: pilihan pembayaran hanya QRIS Kancah; halaman bayar menampilkan QRIS statis `assets/qris-kancah.jpeg`, nominal pesanan, instruksi memasukkan nominal, dan tombol `Saya Sudah Bayar`.
- `supabase/functions/create-payment`: membuat order dari harga server tanpa memanggil gateway.
- `supabase/functions/submit-payment-confirmation`: mengubah order milik pengguna dari `pending` menjadi `waiting_verification`.
- `supabase/functions/verify-manual-payment`: hanya admin di tabel `admins` yang dapat menyetujui/menolak. Persetujuan memanggil RPC `fulfill_order` agar aktivasi tetap dilakukan di backend.
- `admin.html`: daftar transaksi dengan tombol Setujui/Tolak khusus order QRIS manual yang menunggu verifikasi.

## Langkah pemasangan
1. Cadangkan repository dan database sebelum mengganti file.
2. Pastikan `assets/qris-kancah.jpeg` benar-benar QRIS merchant Kancah yang masih aktif. QRIS ini statis, sehingga pembeli wajib memasukkan nominal sendiri.
3. Jalankan migration `supabase/migrations/20261010_manual_qris_checkout.sql` di Supabase SQL Editor (migration ini hanya dokumentasi guardrail dan tidak mengubah tabel).
4. Deploy Edge Functions:

   ```bash
   supabase functions deploy create-payment
   supabase functions deploy submit-payment-confirmation
   supabase functions deploy verify-manual-payment
   ```

5. Pastikan tabel `admins` berisi akun admin yang akan memverifikasi transaksi.
6. **Sebelum menerima uang sungguhan, pastikan RPC `fulfill_order(p_order, p_txn)` memang tersedia dan aman/idempotent.** RPC tersebut harus memperbarui order menjadi `paid` dan membuat/ memperpanjang entitlement berdasarkan `package_id`, `user_id`, dan `months`. Jika RPC tidak ada atau skemanya berbeda, persetujuan admin akan gagal dengan aman dan tidak mengaktifkan Premium.
7. Deploy file frontend ke hosting. Uji dengan pesanan bernilai kecil: buat order, bayar, konfirmasi, periksa transaksi di HP merchant, setujui di admin, lalu pastikan `orders.status = paid` dan entitlement muncul.

## Catatan operasional dan keamanan
- Jangan menyetujui pembayaran hanya dari screenshot. Cocokkan mutasi merchant, nominal, waktu, dan order yang sedang menunggu.
- Karena QRIS statis tidak mengandung ID order atau nominal dinamis, dua pembelian bernominal sama bisa sulit dibedakan. Periksa waktu dan riwayat transaksi; jika ragu, jangan setujui sebelum klarifikasi.
- Tombol “Saya Sudah Bayar” hanya mengubah status ke `waiting_verification`; tidak mengaktifkan Premium.
- Pesanan berlaku 24 jam pada tahap awal. Pengguna yang telanjur membayar setelah kedaluwarsa harus menghubungi admin, jangan membuat pembayaran kedua sebelum transaksi pertama dicek.
- Edge Function `check-payment` dan webhook Pakasir lama tidak lagi dipakai oleh alur checkout QRIS manual. Jangan menghapusnya sampai dipastikan tidak dipakai alur lain.
- Kode masih memakai tabel/kolom existing Cognera (`packages`, `package_prices`, `payment_fees`, `orders`, `admins`, `entitlements`) dan RPC `check_partner_code`. Tes staging dulu karena skema live tidak dapat diverifikasi dari arsip kode saja.
