// POST { order_id }  -> sinkronkan status dengan Midtrans (cadangan kalau webhook telat). Butuh login.
import { admin, applyStatus, authUser, gatewayStatus, json, preflight } from '../_shared/gateway.ts';

Deno.serve(async (req) => {
  const pf = preflight(req); if (pf) return pf;
  try {
    const user = await authUser(req);
    if (!user) return json({ error: 'Silakan masuk dulu.' }, 401);
    const { order_id } = await req.json();

    let { data: order } = await admin.from('orders').select('*').eq('id', order_id).eq('user_id', user.id).maybeSingle();
    if (!order) return json({ error: 'Pesanan tidak ditemukan.' }, 404);

    if (order.status === 'pending' && order.gateway_order_id) {
      const tx = await gatewayStatus(order.gateway_order_id);
      if (tx?.transaction_status) await applyStatus(order, tx);
      // lewat batas waktu tapi gateway belum kirim "expire": tutup sendiri
      else if (order.expires_at && new Date(order.expires_at) < new Date())
        await admin.from('orders').update({ status: 'expired' }).eq('id', order.id).eq('status', 'pending');
      ({ data: order } = await admin.from('orders').select('*').eq('id', order_id).maybeSingle());
    }
    return json({ order });
  } catch (e) {
    console.error(e);
    return json({ error: 'Terjadi kesalahan di server.' }, 500);
  }
});
