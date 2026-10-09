# Integrasi Checkout Cognera dengan Pakasir

Checkout ini mengganti provider pembayaran Midtrans dengan Pakasir. Frontend tetap menggunakan halaman checkout Cognera; QRIS dinamis dibuat melalui Pakasir API v2 dan status pembayaran tidak dipercaya dari browser.

## 1. Pakasir project

1. Buat project di dashboard Pakasir dan salin **slug** serta **API key**.
2. Atur fee payer di dashboard sesuai kebijakan harga Cognera. Kode menghitung biaya layanan Cognera sendiri dan mengirim `orders.amount` ke Pakasir. Untuk menghindari tagihan pembeli lebih besar daripada total checkout, konfigurasi agar biaya Pakasir ditanggung merchant (jika opsi tersebut tersedia di project).
3. Buat webhook URL menuju Supabase Edge Function:

   `https://<PROJECT_REF>.supabase.co/functions/v1/payment-webhook?secret=<RANDOM_SECRET_PANJANG>`

   Gunakan secret acak panjang, bukan API key Pakasir.

## 2. Supabase secrets

Set secrets di Supabase Dashboard > Edge Functions > Secrets atau lewat CLI:

```bash
supabase secrets set PAKASIR_SLUG="slug-project-kamu"
supabase secrets set PAKASIR_API_KEY="api-key-project-kamu"
supabase secrets set PAKASIR_WEBHOOK_SECRET="buat-secret-acak-panjang"
supabase secrets set PAY_EXPIRE_MIN="30"
supabase secrets set ALLOWED_ORIGIN="https://cognera.com"
```

Jangan pernah memasukkan API key atau service-role key ke `app.html`.

## 3. Deploy functions

```bash
supabase functions deploy create-payment
supabase functions deploy check-payment
supabase functions deploy payment-webhook --no-verify-jwt
```

Pastikan `SUPABASE_URL` dan `SUPABASE_SERVICE_ROLE_KEY` tersedia sebagai secrets standar Supabase. Pastikan fungsi SQL `fulfill_order(p_order, p_txn)` memang tersedia dan hanya mengaktifkan order yang valid serta idempotent.

## 4. Database dan pengujian

- Kode ini mengasumsikan tabel `orders`, `packages`, `package_prices`, `payment_fees` dan RPC `check_partner_code` serta `fulfill_order` yang sudah digunakan oleh project Cognera.
- Uji di project sandbox terlebih dahulu jika tersedia. Uji QRIS berhasil, pembayaran pending, nominal tidak cocok, webhook palsu, pesanan kedaluwarsa, klik berulang, dan pembayaran duplikat.
- Status pembayaran dikonfirmasi ulang dari server Pakasir sebelum `fulfill_order` dipanggil. Secret webhook tambahan hanya lapisan proteksi, bukan pengganti verifikasi status server.

## 5. Catatan penting tentang status API

Pembuatan transaksi menggunakan API v2 (`/api/v2/create-transaction/...`). Dokumentasi Pakasir yang tersedia saat integrasi ini dibuat masih menunjukkan endpoint detail transaksi v1 (`/api/transactiondetail`) untuk pemeriksaan status dan menyatakan API v1 dijadwalkan dihentikan pada **20 Oktober 2026**. Karena itu, **jangan aktifkan transaksi produksi setelah tanggal tersebut tanpa mengonfirmasi endpoint status v2 terbaru ke Pakasir** dan memperbarui `gatewayStatus()` di `supabase/functions/_shared/gateway.ts`. Fungsi checkout belum boleh dianggap siap produksi sampai status API v2 diverifikasi.

## Catatan metode pembayaran

- QRIS / GoPay / ShopeePay / DANA pada UI diarahkan ke QRIS.
- Transfer VA yang didukung pada UI: BNI, BRI, Permata.
- BCA dihilangkan dari pilihan karena daftar metode API v2 yang digunakan di integrasi ini tidak mencantumkan BCA VA.
