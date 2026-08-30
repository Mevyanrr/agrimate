import '../../../../core/errors/backend_exception.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._source);

  final ProfileRemoteDataSource _source;

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Success<T>(await action());
    } on BackendException catch (error) {
      return Failure<T>(error.message, code: error.code);
    } catch (error) {
      return Failure<T>('Operasi profile gagal: $error');
    }
  }

  ProfileModel _model(ProfileEntity value) => ProfileModel(
    id: value.id,
    fullName: value.fullName,
    role: value.role,
    businessName: value.businessName,
  );

  @override
  Future<Result<ProfileEntity?>> getMine() => _guard(_source.getMine);

  @override
  Future<Result<ProfileEntity>> create(ProfileEntity profile) =>
      _guard(() => _source.create(_model(profile)));

  @override
  Future<Result<ProfileEntity>> updateMine(ProfileEntity profile) =>
      _guard(() => _source.updateMine(_model(profile)));
}
