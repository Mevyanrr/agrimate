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
      and sf.farmer_id <> v_demand.buyer_id
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
      and df.buyer_id <> v_supply.farmer_id
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

revoke all on function public.run_supply_matching(uuid) from public;
revoke all on function public.run_demand_matching(uuid) from public;
grant execute on function public.run_supply_matching(uuid) to authenticated;
grant execute on function public.run_demand_matching(uuid) to authenticated;

 drop policy if exists profiles_select_match_counterparty on public.profiles;
create policy profiles_select_match_counterparty
on public.profiles
for select
to authenticated
using (
  id = auth.uid()
  or exists (
    select 1
    from public.matches m
    join public.supply_forecasts s on s.id = m.supply_id
    join public.demand_forecasts d on d.id = m.demand_id
    where (s.farmer_id = auth.uid() and d.buyer_id = profiles.id)
       or (d.buyer_id = auth.uid() and s.farmer_id = profiles.id)
  )
);
