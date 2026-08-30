import 'dart:typed_data';

import '../../../../core/errors/backend_exception.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/identity_verification.dart';
import '../../domain/repositories/identity_verification_repository.dart';
import '../datasources/identity_verification_remote_data_source.dart';

class IdentityVerificationRepositoryImpl
    implements IdentityVerificationRepository {
  const IdentityVerificationRepositoryImpl(this._source);
  final IdentityVerificationRemoteDataSource _source;

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Success<T>(await action());
    } on BackendException catch (error) {
      return Failure<T>(error.message, code: error.code);
    } catch (error) {
      return Failure<T>('Operasi verifikasi identitas gagal: $error');
    }
  }

  @override
  Future<Result<IdentityVerification?>> getMine() => _guard(_source.getMine);

  @override
  Future<Result<String>> submitFarmer({required Uint8List ktpBytes}) =>
      _guard(() => _source.submitFarmer(ktpBytes: ktpBytes));

  @override
  Future<Result<String>> submitBuyer({
    required Uint8List ktpBytes,
    required Uint8List npwpBytes,
  }) => _guard(
    () => _source.submitBuyer(ktpBytes: ktpBytes, npwpBytes: npwpBytes),
  );
}
