create or replace function public.current_user_role()
returns text language sql stable security definer set search_path = public
as $$ select role from public.profiles where id = auth.uid() limit 1 $$;

create or replace function public.current_user_province()
returns text language sql stable security definer set search_path = public
as $$ select province from public.profiles where id = auth.uid() limit 1 $$;

revoke all on function public.current_user_role() from public;
revoke all on function public.current_user_province() from public;
grant execute on function public.current_user_role() to authenticated;
grant execute on function public.current_user_province() to authenticated;

alter table public.supply_forecasts enable row level security;
alter table public.demand_forecasts enable row level security;
alter table public.matches enable row level security;
alter table public.transactions enable row level security;
alter table public.notifications enable row level security;

drop policy if exists "supply_read_authenticated" on public.supply_forecasts;
drop policy if exists "farmer_insert_own_supply" on public.supply_forecasts;
drop policy if exists "farmer_update_own_supply" on public.supply_forecasts;
drop policy if exists "farmer_delete_own_supply" on public.supply_forecasts;

create policy "supply_read_authenticated"
on public.supply_forecasts for select to authenticated
using (
  farmer_id = auth.uid()
  or (
    public.current_user_role() = 'BUYER'
    and public.normalize_province(province) =
        public.normalize_province(public.current_user_province())
    and status in ('ACTIVE', 'PARTIALLY_MATCHED')
    and remaining_quantity > 0
  )
);
create policy "farmer_insert_own_supply"
on public.supply_forecasts for insert to authenticated
with check (
  farmer_id = auth.uid()
  and public.current_user_role() = 'FARMER'
  and nullif(public.normalize_province(province), '') is not null
  and public.normalize_province(province) =
      public.normalize_province(public.current_user_province())
);
create policy "farmer_update_own_supply"
on public.supply_forecasts for update to authenticated
using (farmer_id = auth.uid() and public.current_user_role() = 'FARMER')
with check (
  farmer_id = auth.uid()
  and public.normalize_province(province) =
      public.normalize_province(public.current_user_province())
);
create policy "farmer_delete_own_supply"
on public.supply_forecasts for delete to authenticated
using (farmer_id = auth.uid() and public.current_user_role() = 'FARMER');

drop policy if exists "demand_read_authenticated" on public.demand_forecasts;
drop policy if exists "buyer_insert_own_demand" on public.demand_forecasts;
drop policy if exists "buyer_update_own_demand" on public.demand_forecasts;
drop policy if exists "buyer_delete_own_demand" on public.demand_forecasts;

create policy "demand_read_authenticated"
on public.demand_forecasts for select to authenticated
using (
  buyer_id = auth.uid()
  or (
    public.current_user_role() = 'FARMER'
    and public.normalize_province(province) =
        public.normalize_province(public.current_user_province())
    and status in ('ACTIVE', 'PARTIALLY_MATCHED')
    and remaining_quantity > 0
  )
);
create policy "buyer_insert_own_demand"
on public.demand_forecasts for insert to authenticated
with check (
  buyer_id = auth.uid()
  and public.current_user_role() = 'BUYER'
  and nullif(public.normalize_province(province), '') is not null
  and public.normalize_province(province) =
      public.normalize_province(public.current_user_province())
);
create policy "buyer_update_own_demand"
on public.demand_forecasts for update to authenticated
using (buyer_id = auth.uid() and public.current_user_role() = 'BUYER')
with check (
  buyer_id = auth.uid()
  and public.normalize_province(province) =
      public.normalize_province(public.current_user_province())
);
create policy "buyer_delete_own_demand"
on public.demand_forecasts for delete to authenticated
using (buyer_id = auth.uid() and public.current_user_role() = 'BUYER');

drop policy if exists "matches_select_involved_user" on public.matches;
create policy "matches_select_involved_user"
on public.matches for select to authenticated
using (
  exists (select 1 from public.supply_forecasts s
          where s.id = matches.supply_id and s.farmer_id = auth.uid())
  or exists (select 1 from public.demand_forecasts d
             where d.id = matches.demand_id and d.buyer_id = auth.uid())
);

drop policy if exists "transactions_select_involved_user" on public.transactions;
create policy "transactions_select_involved_user"
on public.transactions for select to authenticated
using (farmer_id = auth.uid() or buyer_id = auth.uid());

drop policy if exists "notifications_select_own" on public.notifications;
drop policy if exists "notifications_update_own" on public.notifications;
create policy "notifications_select_own"
on public.notifications for select to authenticated using (user_id = auth.uid());
create policy "notifications_update_own"
on public.notifications for update to authenticated
using (user_id = auth.uid()) with check (user_id = auth.uid());

-- No INSERT/UPDATE policy is intentionally granted on matches or transactions.
