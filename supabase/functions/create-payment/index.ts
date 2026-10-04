// POST { package_id, method, partner_code? }  (butuh login)
// Harga dihitung di server. Mengembalikan baris pesanan lengkap dengan data bayar (QR / nomor VA).
import { admin, authUser, charge, EXPIRE_MIN, feeFor, json, preflight } from '../_shared/gateway.ts';

// method di UI -> cara bayar. Semua e-wallet diarahkan ke satu QRIS.
const WALLETS = ['gopay', 'shopeepay', 'dana', 'qris'];
const BANKS = ['bca', 'bni', 'bri', 'permata'];
const MIN_TOTAL = 1000; // batas bawah nominal gateway

Deno.serve(async (req) => {
  const pf = preflight(req); if (pf) return pf;
  try {
    const user = await authUser(req);
    if (!user) return json({ error: 'Silakan masuk dulu.' }, 401);

    const { package_id, method, partner_code, months: mo } = await req.json();
    const months = Number(mo ?? 12);
    if (![1, 3, 6, 12].includes(months)) return json({ error: 'Durasi tidak valid.' }, 400);
    const type = WALLETS.includes(method) ? 'qris' : BANKS.includes(method) ? 'va' : null;
    if (!type) return json({ error: 'Metode pembayaran tidak dikenal.' }, 400);

    const { data: pkg } = await admin.from('packages').select('*').eq('id', package_id).eq('active', true).maybeSingle();
    if (!pkg) return json({ error: 'Paket tidak ditemukan.' }, 404);

    // harga sesuai durasi (sumber kebenaran: tabel package_prices; 12 bulan jatuh ke packages.price)
    const { data: pp } = await admin.from('package_prices').select('price').eq('package_id', pkg.id).eq('months', months).maybeSingle();
    const unitPrice = pp?.price ?? (months === 12 ? pkg.price : null);
    if (!unitPrice) return json({ error: 'Harga untuk durasi ini belum tersedia.' }, 404);

    // pakai ulang pesanan pending yang belum kedaluwarsa (anti tagihan ganda saat refresh/klik dua kali)
    const wantCode = partner_code ? String(partner_code).trim().toUpperCase() : null;
    let q = admin.from('orders').select('*').eq('user_id', user.id).eq('package_id', pkg.id)
      .eq('method', method).eq('months', months).eq('status', 'pending').gt('expires_at', new Date().toISOString());
    q = wantCode ? q.eq('partner_code', wantCode) : q.is('partner_code', null);
    const { data: dup } = await q.limit(1).maybeSingle();
    if (dup && dup.pay_data) return json({ order: dup });

    // diskon kode mitra (dihitung di server)
    let disc = 0, code: string | null = null;
    if (partner_code) {
      const { data: c } = await admin.rpc('check_partner_code', { p_code: String(partner_code) });
      const row = Array.isArray(c) ? c[0] : c;
      if (!row) return json({ error: 'Kode mitra tidak valid.' }, 400);
      code = row.code;
      disc = Math.min(unitPrice, (row.discount_amt || 0) + Math.floor(unitPrice * (row.discount_pct || 0) / 100));
    }
    const base = Math.max(unitPrice - disc, MIN_TOTAL);
    const { data: rule } = await admin.from('payment_fees').select('*').eq('type', 'all').maybeSingle();
    const fee = feeFor(base, rule);
    const total = base + fee; // yang dibayar pembeli
    const expires = new Date(Date.now() + EXPIRE_MIN * 60_000).toISOString();

    const { data: order, error } = await admin.from('orders').insert({
      user_id: user.id, package_id: pkg.id, amount: total, fee, months, method, pay_option: type,
      partner_code: code, discount: disc, gateway: 'midtrans', pay_type: type, expires_at: expires,
    }).select().single();
    if (error) throw error;

    const gid = 'CG-' + order.order_no;
    const r = await charge({
      orderId: gid, amount: total, type, bank: type === 'va' ? method : undefined,
      item: `${pkg.name} ${months} bulan`, email: user.email ?? undefined,
    });
    if (!['200', '201'].includes(String(r.status_code))) {
      await admin.from('orders').update({ status: 'failed', note: String(r.status_message ?? 'gagal membuat tagihan') }).eq('id', order.id);
      console.error('charge gagal', r);
      return json({ error: 'Gagal membuat tagihan. Coba lagi sebentar.' }, 502);
    }

    const pay_data = type === 'qris'
      ? { qr_string: r.qr_string, qr_url: (r.actions ?? []).find((a: any) => a.name === 'generate-qr-code')?.url ?? null }
      : { bank: method, va_number: r.va_numbers?.[0]?.va_number ?? r.permata_va_number ?? null };

    const { data: saved, error: e2 } = await admin.from('orders')
      .update({ gateway_order_id: gid, gateway_txn_id: r.transaction_id ?? null, pay_data }).eq('id', order.id).select().single();
    if (e2) throw e2;
    return json({ order: saved });
  } catch (e) {
    console.error(e);
    return json({ error: 'Terjadi kesalahan di server.' }, 500);
  }
});
