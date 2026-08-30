# Backend

Folder ini memakai pola clean architecture untuk kode yang berhubungan dengan
API/Supabase. Setiap feature memisahkan domain, model, data source, dan
repository agar UI tidak menjalankan query Supabase secara langsung.

Alur dependensi:

`UI -> use case -> repository contract -> repository implementation -> data source -> Supabase`

Feature yang tersedia: profile, identity verification, commodities, supply,
demand, matches, transactions, dan notifications. Untuk feature baru, ikuti
struktur salah satu feature tersebut dan daftarkan repository-nya dalam
`backend_dependencies.dart`.

Jangan menaruh widget, `BuildContext`, atau state UI di dalam folder ini.
