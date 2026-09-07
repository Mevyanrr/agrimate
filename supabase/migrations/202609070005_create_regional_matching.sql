-- Rule-based regional matching with immutable BAPANAS price snapshots.

alter table public.matches
  add column if not exists province text,
  add column if not exists reference_price numeric,
  add column if not exists price_source text,
  add column if not exists price_source_date date,
  add column if not exists price_region_level text,
  add column if not exists price_province text;

alter table public.transactions
  add column if not exists price_region_level text,
  add column if not exists price_province text;

create index if not exists commodity_prices_regional_lookup_idx
  on public.commodity_prices
  (commodity_id, market_level, region_level, province, source, source_date desc);

create index if not exists supply_forecasts_regional_match_idx
  on public.supply_forecasts
  (commodity_id, province, harvest_start_date, harvest_end_date)
  where remaining_quantity > 0 and status in ('ACTIVE', 'PARTIALLY_MATCHED');

create index if not exists demand_forecasts_regional_match_idx
  on public.demand_forecasts
  (commodity_id, province, needed_start_date, needed_end_date)
  where remaining_quantity > 0 and status in ('ACTIVE', 'PARTIALLY_MATCHED');

do $$
begin
  if exists (
    select 1 from public.matches
    group by supply_id, demand_id having count(*) > 1
  ) then
    raise exception 'Cannot add matches uniqueness: duplicate supply/demand pairs exist';
  end if;
end $$;

create unique index if not exists matches_supply_demand_unique_idx
  on public.matches (supply_id, demand_id);

do $$
begin
  if exists (
    select 1 from public.transactions
    group by match_id having count(*) > 1
  ) then
    raise exception 'Cannot add transaction uniqueness: duplicate match_id values exist';
  end if;
end $$;

create unique index if not exists transactions_match_unique_idx
  on public.transactions (match_id);

create or replace function public.normalize_province(p_value text)
returns text
language sql
immutable
parallel safe
as $$
  select lower(regexp_replace(trim(coalesce(p_value, '')), '\s+', ' ', 'g'))
$$;

create or replace function public.get_reference_price(
  p_commodity_id uuid,
  p_province text
)
returns table(
  price numeric,
  source text,
  source_date date,
  region_level text,
  province text
)
language sql
security definer
set search_path = public
as $$
  select cp.price, cp.source, cp.source_date, cp.region_level, cp.province
  from public.commodity_prices cp
  where cp.commodity_id = p_commodity_id
    and cp.market_level = 'PRODUCER'
    and cp.source = 'BAPANAS'
    and (
      (
        cp.region_level = 'PROVINCE'
        and public.normalize_province(cp.province) =
            public.normalize_province(p_province)
      )
      or (cp.region_level = 'NATIONAL' and cp.province is null)
    )
  order by
    case when cp.region_level = 'PROVINCE' then 0 else 1 end,
    cp.source_date desc,
    cp.fetched_at desc
  limit 1
$$;

revoke all on function public.get_reference_price(uuid, text) from public;
grant execute on function public.get_reference_price(uuid, text) to authenticated;

create or replace function public.run_demand_matching(p_demand_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_demand public.demand_forecasts%rowtype;
  v_supply public.supply_forecasts%rowtype;
  v_needed numeric;
  v_allocation numeric;
  v_match_id uuid;
  v_price record;
begin
  if auth.uid() is null then raise exception 'User is not authenticated'; end if;

  select * into v_demand from public.demand_forecasts
  where id = p_demand_id for update;
  if not found then raise exception 'Demand not found'; end if;
  if auth.uid() <> v_demand.buyer_id then raise exception 'You do not own this demand'; end if;
  if v_demand.status not in ('ACTIVE', 'PARTIALLY_MATCHED') then
    raise exception 'Demand is not available for matching';
  end if;
  if nullif(public.normalize_province(v_demand.province), '') is null then
    raise exception 'Demand province is required';
  end if;
  if v_demand.remaining_quantity <= 0 then return; end if;

  v_needed := v_demand.remaining_quantity;
  for v_supply in
    select sf.* from public.supply_forecasts sf
    where sf.commodity_id = v_demand.commodity_id
      and public.normalize_province(sf.province) =
          public.normalize_province(v_demand.province)
      and sf.status in ('ACTIVE', 'PARTIALLY_MATCHED')
      and sf.remaining_quantity > 0
      and sf.harvest_start_date <= v_demand.needed_end_date
      and sf.harvest_end_date >= v_demand.needed_start_date
      and not exists (
        select 1 from public.matches m
        where m.supply_id = sf.id and m.demand_id = v_demand.id
      )
    order by sf.created_at
    for update of sf skip locked
  loop
    exit when v_needed <= 0;
    v_allocation := least(v_needed, v_supply.remaining_quantity);

    select * into v_price
    from public.get_reference_price(v_demand.commodity_id, v_demand.province);
    if not found then raise exception 'BAPANAS reference price not found'; end if;

    insert into public.matches (
      supply_id, demand_id, matched_quantity, status, province,
      reference_price, price_source, price_source_date,
      price_region_level, price_province
    ) values (
      v_supply.id, v_demand.id, v_allocation, 'POTENTIAL', v_demand.province,
      v_price.price, v_price.source, v_price.source_date,
      v_price.region_level, v_price.province
    ) returning id into v_match_id;

    perform public.create_match_notifications(v_match_id);

    update public.supply_forecasts
    set remaining_quantity = remaining_quantity - v_allocation,
        status = case when remaining_quantity - v_allocation = 0
          then 'FULLY_MATCHED' else 'PARTIALLY_MATCHED' end,
        updated_at = now()
    where id = v_supply.id;
    v_needed := v_needed - v_allocation;
  end loop;

  update public.demand_forecasts
  set remaining_quantity = v_needed,
      status = case when v_needed = 0 then 'FULLY_MATCHED'
        when v_needed < quantity then 'PARTIALLY_MATCHED' else 'ACTIVE' end,
      updated_at = now()
  where id = v_demand.id;
end;
$$;

create or replace function public.run_supply_matching(p_supply_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_supply public.supply_forecasts%rowtype;
  v_demand public.demand_forecasts%rowtype;
  v_available numeric;
  v_allocation numeric;
  v_match_id uuid;
  v_price record;
begin
  if auth.uid() is null then raise exception 'User is not authenticated'; end if;

  select * into v_supply from public.supply_forecasts
  where id = p_supply_id for update;
  if not found then raise exception 'Supply not found'; end if;
  if auth.uid() <> v_supply.farmer_id then raise exception 'You do not own this supply'; end if;
  if v_supply.status not in ('ACTIVE', 'PARTIALLY_MATCHED') then
    raise exception 'Supply is not available for matching';
  end if;
  if nullif(public.normalize_province(v_supply.province), '') is null then
    raise exception 'Supply province is required';
  end if;
  if v_supply.remaining_quantity <= 0 then return; end if;

  v_available := v_supply.remaining_quantity;
  for v_demand in
    select df.* from public.demand_forecasts df
    where df.commodity_id = v_supply.commodity_id
      and public.normalize_province(df.province) =
          public.normalize_province(v_supply.province)
      and df.status in ('ACTIVE', 'PARTIALLY_MATCHED')
      and df.remaining_quantity > 0
      and df.needed_start_date <= v_supply.harvest_end_date
      and df.needed_end_date >= v_supply.harvest_start_date
      and not exists (
        select 1 from public.matches m
        where m.supply_id = v_supply.id and m.demand_id = df.id
      )
    order by df.created_at
    for update of df skip locked
  loop
    exit when v_available <= 0;
    v_allocation := least(v_available, v_demand.remaining_quantity);

    select * into v_price
    from public.get_reference_price(v_supply.commodity_id, v_supply.province);
    if not found then raise exception 'BAPANAS reference price not found'; end if;

    insert into public.matches (
      supply_id, demand_id, matched_quantity, status, province,
      reference_price, price_source, price_source_date,
      price_region_level, price_province
    ) values (
      v_supply.id, v_demand.id, v_allocation, 'POTENTIAL', v_supply.province,
      v_price.price, v_price.source, v_price.source_date,
      v_price.region_level, v_price.province
    ) returning id into v_match_id;

    perform public.create_match_notifications(v_match_id);

    update public.demand_forecasts
    set remaining_quantity = remaining_quantity - v_allocation,
        status = case when remaining_quantity - v_allocation = 0
          then 'FULLY_MATCHED' else 'PARTIALLY_MATCHED' end,
        updated_at = now()
    where id = v_demand.id;
    v_available := v_available - v_allocation;
  end loop;

  update public.supply_forecasts
  set remaining_quantity = v_available,
      status = case when v_available = 0 then 'FULLY_MATCHED'
        when v_available < quantity then 'PARTIALLY_MATCHED' else 'ACTIVE' end,
      updated_at = now()
  where id = v_supply.id;
end;
$$;

create or replace function public.reject_match(p_match_id uuid)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  v_match public.matches%rowtype;
  v_supply public.supply_forecasts%rowtype;
  v_demand public.demand_forecasts%rowtype;
begin
  if auth.uid() is null then raise exception 'User is not authenticated'; end if;
  select * into v_match from public.matches where id = p_match_id for update;
  if not found then raise exception 'Match not found'; end if;
  if v_match.status = 'REJECTED' then return 'REJECTED'; end if;
  if v_match.status in ('CONFIRMED', 'CANCELLED') then
    raise exception 'Match cannot be rejected';
  end if;

  select * into v_supply from public.supply_forecasts
  where id = v_match.supply_id for update;
  select * into v_demand from public.demand_forecasts
  where id = v_match.demand_id for update;
  if auth.uid() <> v_supply.farmer_id and auth.uid() <> v_demand.buyer_id then
    raise exception 'User is not part of this match';
  end if;

  update public.supply_forecasts
  set remaining_quantity = least(quantity, remaining_quantity + v_match.matched_quantity),
      status = case
        when least(quantity, remaining_quantity + v_match.matched_quantity) = quantity then 'ACTIVE'
        else 'PARTIALLY_MATCHED' end,
      updated_at = now()
  where id = v_supply.id;

  update public.demand_forecasts
  set remaining_quantity = least(quantity, remaining_quantity + v_match.matched_quantity),
      status = case
        when least(quantity, remaining_quantity + v_match.matched_quantity) = quantity then 'ACTIVE'
        else 'PARTIALLY_MATCHED' end,
      updated_at = now()
  where id = v_demand.id;

  update public.matches set status = 'REJECTED', updated_at = now()
  where id = p_match_id;
  return 'REJECTED';
end;
$$;

create or replace function public.create_transaction_from_match(p_match_id uuid)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_match public.matches%rowtype;
  v_supply public.supply_forecasts%rowtype;
  v_demand public.demand_forecasts%rowtype;
  v_transaction_id uuid;
  v_fee_percentage numeric := 5;
  v_subtotal numeric;
begin
  select * into v_match from public.matches where id = p_match_id for update;
  if not found then raise exception 'Match not found'; end if;
  if v_match.status <> 'CONFIRMED' then raise exception 'Match is not confirmed'; end if;
  if v_match.reference_price is null then raise exception 'Match price snapshot is missing'; end if;

  select * into v_supply from public.supply_forecasts where id = v_match.supply_id;
  select * into v_demand from public.demand_forecasts where id = v_match.demand_id;
  v_subtotal := v_match.matched_quantity * v_match.reference_price;

  insert into public.transactions (
    match_id, farmer_id, buyer_id, commodity_id, quantity,
    reference_price, price_source, price_source_date,
    price_region_level, price_province,
    subtotal, fee_percentage, fee_amount, total_amount, status
  ) values (
    v_match.id, v_supply.farmer_id, v_demand.buyer_id, v_supply.commodity_id,
    v_match.matched_quantity, v_match.reference_price, v_match.price_source,
    v_match.price_source_date, v_match.price_region_level, v_match.price_province,
    v_subtotal, v_fee_percentage, v_subtotal * v_fee_percentage / 100,
    v_subtotal + (v_subtotal * v_fee_percentage / 100), 'CONFIRMED'
  )
  on conflict (match_id) do update set match_id = excluded.match_id
  returning id into v_transaction_id;
  return v_transaction_id;
end;
$$;

revoke all on function public.run_supply_matching(uuid) from public;
revoke all on function public.run_demand_matching(uuid) from public;
revoke all on function public.reject_match(uuid) from public;
revoke all on function public.create_transaction_from_match(uuid) from public;
grant execute on function public.run_supply_matching(uuid) to authenticated;
grant execute on function public.run_demand_matching(uuid) to authenticated;
grant execute on function public.reject_match(uuid) to authenticated;

-- create_transaction_from_match is intentionally not granted to clients;
-- confirm_match invokes it internally after dual confirmation.
