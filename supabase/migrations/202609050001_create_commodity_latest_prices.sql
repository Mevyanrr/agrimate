create or replace view public.commodity_latest_prices
with (security_invoker = true)
as
select distinct on (c.id)
  c.id as commodity_id,
  c.name,
  c.unit,
  c.price_source_name,
  cp.price,
  cp.source,
  cp.source_date,
  cp.source_period,
  cp.market_level,
  cp.region_level
from public.commodities c
join public.commodity_prices cp
  on cp.commodity_id = c.id
where c.is_active = true
  and cp.market_level = 'PRODUCER'
  and cp.region_level = 'NATIONAL'
order by
  c.id,
  cp.source_date desc,
  cp.fetched_at desc;

grant select on public.commodity_latest_prices to authenticated;
