# Deploy Edge Functions lewat Supabase Dashboard (single-file)

Tiga fungsi pembayaran QRIS manual sudah dibuat mandiri: seluruh helper yang diperlukan ditaruh langsung di masing-masing `index.ts`, tanpa import `../_shared/gateway.ts`.

## Cara deploy
1. Buka Supabase Dashboard → Edge Functions.
2. Pilih `create-payment` (buat fungsi jika belum ada), buka editor `index.ts`, ganti seluruh isi dengan file lokal `supabase/functions/create-payment/index.ts`, lalu Deploy.
3. Ulangi untuk `submit-payment-confirmation` dan `verify-manual-payment`. Nama fungsi harus persis sama.
4. Pastikan secret `SUPABASE_URL` dan `SUPABASE_SERVICE_ROLE_KEY` tersedia di Edge Function secrets (biasanya `SUPABASE_URL` dan service role key tersedia otomatis di Supabase). Jangan pernah menaruh service role key di frontend.
5. Jalankan migration `supabase/migrations/20261010_manual_qris_checkout.sql` di SQL Editor jika belum dijalankan.

## Penting
- Fungsi verifikasi hanya mengizinkan pengguna yang tercatat pada tabel `admins`.
- `verify-manual-payment` memanggil RPC `fulfill_manual_qris_order`; migration harus berhasil sebelum approval dipakai.
- Konfirmasi dari pengguna hanya mengubah status menjadi `waiting_verification`; bukan bukti pembayaran dan tidak otomatis mengaktifkan Premium. Admin harus memeriksa mutasi/riwayat pembayaran terlebih dahulu.
- Paket ini belum membuktikan konfigurasi database live atau deployment berhasil. Uji dengan transaksi percobaan sebelum dipakai sungguhan.
