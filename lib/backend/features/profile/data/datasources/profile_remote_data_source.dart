import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/database_tables.dart';
import '../../../../core/errors/backend_exception.dart';
import '../models/example_model.dart';

abstract interface class ExampleRemoteDataSource {
  Future<List<ExampleModel>> getAll();
}

class SupabaseExampleRemoteDataSource implements ExampleRemoteDataSource {
  const SupabaseExampleRemoteDataSource(this._client);

  final SupabaseClient _client;

  @override
  Future<List<ExampleModel>> getAll() async {
    try {
      // TODO: Tambahkan select, filter, order, atau pagination yang dibutuhkan.
      final rows = await _client.from(DatabaseTables.examples).select();
      return rows.map(ExampleModel.fromJson).toList();
    } on PostgrestException catch (error) {
      throw BackendException(
        error.message,
        code: error.code,
        originalError: error,
      );
    } catch (error) {
      throw BackendException(
        'Gagal mengambil data example.',
        originalError: error,
      );
    }
  }
}

