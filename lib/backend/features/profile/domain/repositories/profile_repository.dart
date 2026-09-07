import 'dart:typed_data';

import '../../../../core/result/result.dart';
import '../entities/profile_entity.dart';

abstract interface class ProfileRepository {
  Future<Result<ProfileEntity?>> getMine();
  Future<Result<ProfileEntity>> create(ProfileEntity profile);
  Future<Result<ProfileEntity>> updateMine(ProfileEntity profile);
  Future<Result<String>> uploadPhoto({
    required Uint8List bytes,
    required String fileName,
  });
}
