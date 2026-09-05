alter table public.demand_forecasts
add column if not exists forecast_source text
not null default 'MANUAL'
check (forecast_source in ('MANUAL', 'AI'));
