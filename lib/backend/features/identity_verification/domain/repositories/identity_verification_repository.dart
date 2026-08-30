import 'dart:typed_data';

import '../../../../core/result/result.dart';
import '../entities/identity_verification.dart';

abstract interface class IdentityVerificationRepository {
  Future<Result<IdentityVerification?>> getMine();
  Future<Result<String>> submitFarmer({required Uint8List ktpBytes});
  Future<Result<String>> submitBuyer({
    required Uint8List ktpBytes,
    required Uint8List npwpBytes,
  });
}
