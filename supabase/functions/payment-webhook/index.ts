// Dipanggil Midtrans setiap status berubah (bayar / kedaluwarsa).
// Deploy dengan:  supabase functions deploy payment-webhook --no-verify-jwt
import { admin, applyStatus, gatewayStatus, sha512 } from '../_shared/gateway.ts';

const key = Deno.env.get('MIDTRANS_SERVER_KEY') ?? '';
const ok = (m = 'ok') => new Response(m, { status: 200 });

Deno.serve(async (req) => {
  if (req.method !== 'POST') return new Response('Method not allowed', { status: 405 });
  try {
    const n = await req.json();
    // 1) tanda tangan: sha512(order_id + status_code + gross_amount + server_key)
    const sig = await sha512(`${n.order_id}${n.status_code}${n.gross_amount}${key}`);
    if (!n.signature_key || sig !== n.signature_key) return new Response('Invalid signature', { status: 403 });

    const { data: order } = await admin.from('orders').select('*').eq('gateway_order_id', n.order_id).maybeSingle();
    if (!order) return ok('order tidak dikenal'); // mis. tes dari dashboard Midtrans

    // 2) jangan percaya isi webhook mentah-mentah: konfirmasi ulang ke API status Midtrans
    const tx = await gatewayStatus(n.order_id);
    if (!tx || !tx.transaction_status) return new Response('Status tidak tersedia', { status: 502 });

    await applyStatus(order, tx);
    return ok();
  } catch (e) {
    console.error('webhook error', e);
    return new Response('error', { status: 500 }); // Midtrans akan mengulang pengiriman
  }
});
