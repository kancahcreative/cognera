# Entitlement: pengecekan akses Premium

Entitlement adalah catatan hak akses yang dimiliki sebuah akun setelah pembayaran diverifikasi. Biasanya record berada di tabel `entitlements` dan menghubungkan `user_id`, `package_id`, serta masa aktif seperti `ends_at`.

Jika akun sudah membayar tetapi tryout masih terkunci, periksa di Supabase:
1. Pastikan ada record entitlement untuk `user_id` akun yang sedang login.
2. Pastikan `package_id` sama dengan paket yang mencakup tryout tersebut (contoh jalur UTBK/SNBT).
3. Pastikan `ends_at` belum lewat dan nilainya memakai timestamp yang benar.
4. Pastikan status pembayaran benar-benar `paid`/terverifikasi dan proses pemberian entitlement berjalan setelah pembayaran.
5. Periksa RLS agar pengguna dapat membaca entitlement miliknya sendiri; jangan membuka akses untuk mengubah entitlement sendiri.
6. Periksa apakah aturan tryout memeriksa entitlement yang sama dan tidak hanya nama paket yang ditampilkan di UI.

Jangan membuat entitlement manual tanpa mencocokkan transaksi yang lunas. Perubahan UI saja tidak dapat memperbaiki record Supabase yang hilang atau salah.
