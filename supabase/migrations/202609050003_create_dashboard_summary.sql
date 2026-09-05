create or replace function public.get_dashboard_summary()
returns json
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_role text;
  v_active_count bigint := 0;
  v_match_count bigint := 0;
  v_transaction_count bigint := 0;
  v_transaction_value numeric := 0;
begin
  if v_user_id is null then
    raise exception 'User is not authenticated';
  end if;

  select role into v_role from public.profiles where id = v_user_id;
  if not found then raise exception 'Profile not found'; end if;

  if v_role = 'FARMER' then
    select count(*) into v_active_count
    from public.supply_forecasts
    where farmer_id = v_user_id and status in ('ACTIVE', 'PARTIALLY_MATCHED');

    select count(*) into v_match_count
    from public.matches m
    join public.supply_forecasts s on s.id = m.supply_id
    where s.farmer_id = v_user_id
      and m.status in ('POTENTIAL', 'FARMER_CONFIRMED', 'BUYER_CONFIRMED');

    select count(*), coalesce(sum(total_amount), 0)
    into v_transaction_count, v_transaction_value
    from public.transactions where farmer_id = v_user_id;
  elsif v_role = 'BUYER' then
    select count(*) into v_active_count
    from public.demand_forecasts
    where buyer_id = v_user_id and status in ('ACTIVE', 'PARTIALLY_MATCHED');

    select count(*) into v_match_count
    from public.matches m
    join public.demand_forecasts d on d.id = m.demand_id
    where d.buyer_id = v_user_id
      and m.status in ('POTENTIAL', 'FARMER_CONFIRMED', 'BUYER_CONFIRMED');

    select count(*), coalesce(sum(total_amount), 0)
    into v_transaction_count, v_transaction_value
    from public.transactions where buyer_id = v_user_id;
  else
    raise exception 'Unknown user role';
  end if;

  return json_build_object(
    'role', v_role,
    'active_forecasts', v_active_count,
    'potential_matches', v_match_count,
    'transactions', v_transaction_count,
    'transaction_value', v_transaction_value
  );
end;
$$;

revoke all on function public.get_dashboard_summary() from public;
grant execute on function public.get_dashboard_summary() to authenticated;
