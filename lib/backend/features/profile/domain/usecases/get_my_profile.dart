import '../../../../core/result/result.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class GetMyProfile {
  const GetMyProfile(this._repository);

  final ProfileRepository _repository;

  Future<Result<ProfileEntity?>> call() => _repository.getMine();
}
