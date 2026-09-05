create table if not exists public.identity_documents (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references public.profiles(id) on delete cascade,
  ktp_path text not null,
  npwp_path text,
  submitted_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.identity_documents enable row level security;

create policy "Users can read their identity documents"
on public.identity_documents for select to authenticated
using (user_id = auth.uid());

create policy "Users can insert their identity documents"
on public.identity_documents for insert to authenticated
with check (user_id = auth.uid());

create policy "Users can update their identity documents"
on public.identity_documents for update to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

insert into storage.buckets (id, name, public)
values ('identity-documents', 'identity-documents', false)
on conflict (id) do update set public = false;

create policy "Users can upload their identity documents"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'identity-documents'
  and (storage.foldername(name))[1] = auth.uid()::text
);

create policy "Users can update their identity documents"
on storage.objects for update to authenticated
using (
  bucket_id = 'identity-documents'
  and (storage.foldername(name))[1] = auth.uid()::text
)
with check (
  bucket_id = 'identity-documents'
  and (storage.foldername(name))[1] = auth.uid()::text
);

create policy "Users can read their identity documents"
on storage.objects for select to authenticated
using (
  bucket_id = 'identity-documents'
  and (storage.foldername(name))[1] = auth.uid()::text
);
