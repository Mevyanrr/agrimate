# Backend

Folder ini memakai pola clean architecture untuk kode yang berhubungan dengan
API/Supabase. Ganti nama feature `example` sesuai kebutuhan, misalnya `auth`,
`farms`, `plants`, atau `profiles`.

Alur dependensi:

`UI -> use case -> repository contract -> repository implementation -> data source -> Supabase`

Yang perlu diisi:

1. `core/constants/database_tables.dart`: nama tabel Supabase.
2. `features/example/domain/entities/example_entity.dart`: bentuk data bisnis.
3. `features/example/data/models/example_model.dart`: mapping JSON Supabase.
4. `features/example/data/datasources/example_remote_data_source.dart`: query Supabase.
5. Tambahkan method pada repository dan use case sesuai kebutuhan aplikasi.
6. `backend_dependencies.dart`: daftarkan feature baru agar bisa dipakai UI.

Jangan menaruh widget, `BuildContext`, atau state UI di dalam folder ini.

