alter table public.profiles
  add column if not exists photo_url text;

-- Avatar ditampilkan melalui public URL. Upload/update tetap dilindungi RLS.
update storage.buckets
set
  public = true,
  file_size_limit = 5242880,
  allowed_mime_types = array['image/jpeg', 'image/png', 'image/webp']
where id = 'profil';

-- Dibutuhkan oleh upload dengan `upsert: true` untuk mengecek file lama.
drop policy if exists "Users can read own profile photo" on storage.objects;
create policy "Users can read own profile photo"
on storage.objects for select to authenticated
using (
  bucket_id = 'profil'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "Users can upload own profile photo" on storage.objects;
create policy "Users can upload own profile photo"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'profil'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "Users can update own profile photo" on storage.objects;
create policy "Users can update own profile photo"
on storage.objects for update to authenticated
using (
  bucket_id = 'profil'
  and (storage.foldername(name))[1] = auth.uid()::text
)
with check (
  bucket_id = 'profil'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "Users can delete own profile photo" on storage.objects;
create policy "Users can delete own profile photo"
on storage.objects for delete to authenticated
using (
  bucket_id = 'profil'
  and (storage.foldername(name))[1] = auth.uid()::text
);
