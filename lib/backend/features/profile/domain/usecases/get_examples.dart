import '../../../../core/result/result.dart';
import '../entities/example_entity.dart';
import '../repositories/example_repository.dart';

class GetExamples {
  const GetExamples(this._repository);

  final ExampleRepository _repository;

  Future<Result<List<ExampleEntity>>> call() => _repository.getAll();
}

