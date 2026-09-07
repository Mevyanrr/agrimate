-- Repair legacy matches created before province-aware BAPANAS snapshots.
with resolved_prices as (
  select
    m.id as match_id,
    p.price,
    p.source,
    p.source_date,
    p.region_level,
    p.province
  from public.matches m
  join public.supply_forecasts s on s.id = m.supply_id
  cross join lateral public.get_reference_price(
    s.commodity_id,
    coalesce(m.province, s.province)
  ) p
  where coalesce(m.reference_price, 0) <= 0
)
update public.matches m
set
  reference_price = p.price,
  price_source = p.source,
  price_source_date = p.source_date,
  price_region_level = p.region_level,
  price_province = p.province,
  updated_at = now()
from resolved_prices p
where m.id = p.match_id;

-- Keep an already-created transaction aligned with its immutable match price.
update public.transactions t
set
  reference_price = m.reference_price,
  price_source = m.price_source,
  price_source_date = m.price_source_date,
  subtotal = t.quantity * m.reference_price,
  fee_amount = (t.quantity * m.reference_price) * t.fee_percentage / 100,
  total_amount = (t.quantity * m.reference_price) *
    (1 + t.fee_percentage / 100),
  updated_at = now()
from public.matches m
where t.match_id = m.id
  and coalesce(t.reference_price, 0) <= 0
  and coalesce(m.reference_price, 0) > 0;

-- A transaction participant may read only the counterparty profile needed for
-- transaction contact. This does not expose profiles to unrelated users.
alter table public.profiles enable row level security;

drop policy if exists profiles_select_transaction_counterparty
  on public.profiles;
create policy profiles_select_transaction_counterparty
on public.profiles
for select
to authenticated
using (
  id = auth.uid()
  or exists (
    select 1
    from public.transactions t
    where
      (t.farmer_id = auth.uid() and t.buyer_id = profiles.id)
      or (t.buyer_id = auth.uid() and t.farmer_id = profiles.id)
  )
);
