import '../../../../core/errors/backend_exception.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/example_entity.dart';
import '../../domain/repositories/example_repository.dart';
import '../datasources/example_remote_data_source.dart';

class ExampleRepositoryImpl implements ExampleRepository {
  const ExampleRepositoryImpl(this._remoteDataSource);

  final ExampleRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<ExampleEntity>>> getAll() async {
    try {
      final data = await _remoteDataSource.getAll();
      return Success<List<ExampleEntity>>(data);
    } on BackendException catch (error) {
      return Failure<List<ExampleEntity>>(error.message, code: error.code);
    }
  }
}

