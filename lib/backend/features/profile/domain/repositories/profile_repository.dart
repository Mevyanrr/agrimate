import '../../../../core/result/result.dart';
import '../entities/example_entity.dart';

/// Contract repository. Domain layer tidak boleh mengimpor Supabase.
abstract interface class ExampleRepository {
  Future<Result<List<ExampleEntity>>> getAll();

  // TODO: Tambahkan contract create/update/delete bila diperlukan.
}

