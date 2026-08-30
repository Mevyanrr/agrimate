import '../../domain/entities/example_entity.dart';

/// Model bertanggung jawab mengubah response Supabase menjadi entity.
class ExampleModel extends ExampleEntity {
  const ExampleModel({required super.id, required super.name});

  factory ExampleModel.fromJson(Map<String, dynamic> json) {
    return ExampleModel(
      // TODO: Samakan key berikut dengan nama kolom tabel Supabase.
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // TODO: Jangan kirim `id` jika ID dibuat otomatis oleh database.
      'id': id,
      'name': name,
    };
  }
}

