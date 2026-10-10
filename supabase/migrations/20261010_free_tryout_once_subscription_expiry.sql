-- Cognera: batasi tryout gratis menjadi satu percobaan dan pastikan paket berakhir sesuai durasi.
-- Jalankan sekali di Supabase SQL Editor sebelum deploy frontend.

-- Data tryout gratis yang sudah ada ikut dibatasi satu kali.
update public.tryouts set max_tries = 1 where lower(coalesce(access, 'free')) = 'free';

-- Fungsi bersama: masa aktif entitlement mengikuti durasi order yang sudah dibayar.
create or replace function public.set_entitlement_expiry_from_paid_order()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_months integer;
begin
  select greatest(coalesce(o.months, 12), 1)
    into v_months
    from public.orders o
   where o.user_id = new.user_id
     and o.package_id = new.package_id
     and lower(coalesce(o.status, '')) = 'paid'
   order by o.created_at desc
   limit 1;

  if v_months is not null then
    new.ends_at := now() + make_interval(months => v_months);
  end if;
  return new;
end;
$$;

drop trigger if exists trg_entitlement_expiry_from_paid_order on public.entitlements;
create trigger trg_entitlement_expiry_from_paid_order
before insert on public.entitlements
for each row execute function public.set_entitlement_expiry_from_paid_order();

drop trigger if exists trg_entitlement_expiry_update_from_paid_order on public.entitlements;
create trigger trg_entitlement_expiry_update_from_paid_order
before update of user_id, package_id on public.entitlements
for each row execute function public.set_entitlement_expiry_from_paid_order();

-- Jika order berubah menjadi paid setelah entitlement dibuat, hitung ulang masa aktif.
create or replace function public.sync_entitlement_expiry_after_paid_order()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if lower(coalesce(new.status, '')) = 'paid'
     and lower(coalesce(old.status, '')) is distinct from 'paid' then
    update public.entitlements e
       set ends_at = now() + make_interval(months => greatest(coalesce(new.months, 12), 1))
     where e.user_id = new.user_id
       and e.package_id = new.package_id;
  end if;
  return new;
end;
$$;

drop trigger if exists trg_order_paid_sync_entitlement_expiry on public.orders;
create trigger trg_order_paid_sync_entitlement_expiry
after update of status on public.orders
for each row execute function public.sync_entitlement_expiry_after_paid_order();

-- Backfill entitlement lama yang masih tanpa tanggal kedaluwarsa berdasarkan order paid terakhir.
update public.entitlements e
   set ends_at = (
     select coalesce(ord.created_at, now()) + make_interval(months => greatest(coalesce(ord.months, 12), 1))
       from public.orders ord
      where ord.user_id = e.user_id
        and ord.package_id = e.package_id
        and lower(coalesce(ord.status, '')) = 'paid'
      order by ord.created_at desc
      limit 1
   )
 where e.ends_at is null
   and exists (select 1 from public.orders ord where ord.user_id=e.user_id and ord.package_id=e.package_id and lower(coalesce(ord.status, ''))='paid');
