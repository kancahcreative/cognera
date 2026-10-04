// Helper bersama untuk Edge Functions pembayaran (Midtrans Core API).
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.45.4';

export const admin = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
  { auth: { persistSession: false } },
);

const SERVER_KEY = Deno.env.get('MIDTRANS_SERVER_KEY') ?? '';
const IS_PROD = Deno.env.get('MIDTRANS_IS_PRODUCTION') === 'true';
const BASE = IS_PROD ? 'https://api.midtrans.com' : 'https://api.sandbox.midtrans.com';
const AUTH = 'Basic ' + btoa(SERVER_KEY + ':');
export const EXPIRE_MIN = Number(Deno.env.get('PAY_EXPIRE_MIN') ?? '30');

const cors = {
  'Access-Control-Allow-Origin': Deno.env.get('ALLOWED_ORIGIN') ?? '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};
export const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), { status, headers: { ...cors, 'Content-Type': 'application/json' } });
export const preflight = (req: Request) => (req.method === 'OPTIONS' ? new Response('ok', { headers: cors }) : null);

export async function sha512(s: string) {
  const buf = await crypto.subtle.digest('SHA-512', new TextEncoder().encode(s));
  return [...new Uint8Array(buf)].map((b) => b.toString(16).padStart(2, '0')).join('');
}

/** Ambil user dari JWT di header Authorization. */
export async function authUser(req: Request) {
  const jwt = (req.headers.get('Authorization') ?? '').replace(/^Bearer\s+/i, '');
  if (!jwt) return null;
  const { data, error } = await admin.auth.getUser(jwt);
  return error ? null : data.user;
}

async function mt(path: string, init?: RequestInit) {
  const r = await fetch(BASE + path, {
    ...init,
    headers: { Accept: 'application/json', 'Content-Type': 'application/json', Authorization: AUTH },
  });
  return await r.json();
}

/** Buat tagihan. QRIS (semua e-wallet) atau Virtual Account bank. */
export function charge(p: { orderId: string; amount: number; type: 'qris' | 'va'; bank?: string; item: string; email?: string }) {
  const body: Record<string, unknown> = {
    transaction_details: { order_id: p.orderId, gross_amount: p.amount },
    item_details: [{ id: 'paket', price: p.amount, quantity: 1, name: p.item.slice(0, 50) }],
    customer_details: p.email ? { email: p.email } : undefined,
    custom_expiry: { expiry_duration: EXPIRE_MIN, unit: 'minute' },
  };
  if (p.type === 'qris') { body.payment_type = 'qris'; body.qris = { acquirer: 'gopay' }; }
  else { body.payment_type = 'bank_transfer'; body.bank_transfer = { bank: p.bank }; }
  return mt('/v2/charge', { method: 'POST', body: JSON.stringify(body) });
}

/** Status resmi dari Midtrans (sumber kebenaran, bukan isi webhook). */
export const gatewayStatus = (orderId: string) => mt(`/v2/${encodeURIComponent(orderId)}/status`);

/** Terapkan status gateway ke pesanan. Idempotent. Mengembalikan status pesanan terbaru. */
export async function applyStatus(order: any, tx: any): Promise<string> {
  const ts = tx.transaction_status as string, fraud = tx.fraud_status as string | undefined;
  const paidOk = ts === 'settlement' || (ts === 'capture' && (!fraud || fraud === 'accept'));

  if (paidOk) {
    // nominal harus cocok persis, kalau tidak jangan aktifkan paket
    if (Math.round(Number(tx.gross_amount)) !== Number(order.amount)) {
      console.error('Nominal tidak cocok', order.id, tx.gross_amount, order.amount);
      return order.status;
    }
    const { error } = await admin.rpc('fulfill_order', { p_order: order.id, p_txn: tx.transaction_id ?? null });
    if (error) throw error; // 5xx -> Midtrans akan mengirim ulang webhook
    return 'paid';
  }
  const next = ts === 'expire' ? 'expired' : (ts === 'cancel' || ts === 'deny' || ts === 'failure') ? 'failed' : null;
  if (next) {
    await admin.from('orders').update({ status: next }).eq('id', order.id).eq('status', 'pending');
    return next;
  }
  return order.status; // pending: belum ada perubahan
}

/** Biaya layanan untuk semua metode: (harga + flat*(1+PPN)) lalu dibulatkan ke kelipatan round_to. Mengembalikan nilai biaya. */
export function feeFor(base: number, rule: { pct: number; flat: number; vat_pct: number; round_to: number } | null) {
  if (!rule) return 0;
  const k = 1 + Number(rule.vat_pct) / 100;
  const raw = Math.ceil((base + Number(rule.flat) * k) / (1 - (Number(rule.pct) / 100) * k));
  const r = Number(rule.round_to) || 1;
  return Math.max(0, Math.round(raw / r) * r - base);
}
