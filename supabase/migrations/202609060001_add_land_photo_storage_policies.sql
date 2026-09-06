-- Bucket `land_photo` sudah dibuat lewat Supabase Dashboard.
-- Setiap pengguna hanya boleh mengelola file dalam folder UUID miliknya.

drop policy if exists "Farmers can upload own land photos" on storage.objects;
create policy "Farmers can upload own land photos"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'land_photo'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "Farmers can update own land photos" on storage.objects;
create policy "Farmers can update own land photos"
on storage.objects for update to authenticated
using (
  bucket_id = 'land_photo'
  and (storage.foldername(name))[1] = auth.uid()::text
)
with check (
  bucket_id = 'land_photo'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "Farmers can delete own land photos" on storage.objects;
create policy "Farmers can delete own land photos"
on storage.objects for delete to authenticated
using (
  bucket_id = 'land_photo'
  and (storage.foldername(name))[1] = auth.uid()::text
);
