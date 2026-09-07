import '../../../../core/result/result.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class GetProfiles {
  const GetProfiles(this._repository);

  final ProfileRepository _repository;

  Future<Result<List<ProfileEntity>>> call() => _repository.getAll();
}

