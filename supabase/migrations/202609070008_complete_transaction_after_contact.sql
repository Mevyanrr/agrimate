create or replace function public.complete_transaction_after_contact(
  p_transaction_id uuid
)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  v_transaction public.transactions%rowtype;
begin
  if auth.uid() is null then
    raise exception 'User is not authenticated';
  end if;

  select * into v_transaction
  from public.transactions
  where id = p_transaction_id
  for update;

  if not found then raise exception 'Transaction not found'; end if;
  if auth.uid() <> v_transaction.farmer_id
     and auth.uid() <> v_transaction.buyer_id then
    raise exception 'User is not part of this transaction';
  end if;
  if v_transaction.status in ('CANCELLED', 'REJECTED') then
    raise exception 'Cancelled transaction cannot be completed';
  end if;
  if v_transaction.status in ('COMPLETED', 'DONE') then
    return 'COMPLETED';
  end if;

  update public.transactions
  set status = 'COMPLETED', updated_at = now()
  where id = p_transaction_id;

  return 'COMPLETED';
end;
$$;

revoke all on function public.complete_transaction_after_contact(uuid)
  from public;
grant execute on function public.complete_transaction_after_contact(uuid)
  to authenticated;
