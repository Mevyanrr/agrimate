import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/database_tables.dart';
import '../../../../core/errors/backend_exception.dart';
import '../models/identity_verification_model.dart';

abstract interface class IdentityVerificationRemoteDataSource {
  Future<IdentityVerificationModel?> getMine();
  Future<String> submitFarmer({required Uint8List ktpBytes});
  Future<String> submitBuyer({
    required Uint8List ktpBytes,
    required Uint8List npwpBytes,
  });
}

class SupabaseIdentityVerificationRemoteDataSource
    implements IdentityVerificationRemoteDataSource {
  const SupabaseIdentityVerificationRemoteDataSource(this._client);

  final SupabaseClient _client;

  String get _userId => _client.auth.currentUser?.id ??
      (throw const BackendException(
        'Pengguna belum login.',
        code: 'unauthenticated',
      ));

  @override
  Future<IdentityVerificationModel?> getMine() async {
    final row = await _client
        .from(DatabaseTables.identityVerifications)
        .select()
        .eq('user_id', _userId)
        .maybeSingle();

    return row == null ? null : IdentityVerificationModel.fromJson(row);
  }

  Future<String> _uploadJpeg(String fileName, Uint8List bytes) async {
    if (bytes.isEmpty) {
      throw const BackendException('File dokumen tidak boleh kosong.');
    }

    final path = '$_userId/$fileName';
    await _client.storage.from(StorageBuckets.identityDocuments).uploadBinary(
      path,
      bytes,
      fileOptions: const FileOptions(
        upsert: true,
        contentType: 'image/jpeg',
      ),
    );
    return path;
  }

  Future<String> _submit({
    required String ktpPath,
    String? npwpPath,
  }) async {
    final result = await _client.rpc(
      'submit_identity_verification',
      params: {
        'p_ktp_path': ktpPath,
        'p_npwp_path': npwpPath,
      },
    );
    return result.toString();
  }

  @override
  Future<String> submitFarmer({required Uint8List ktpBytes}) async {
    final ktpPath = await _uploadJpeg('ktp.jpg', ktpBytes);
    return _submit(ktpPath: ktpPath);
  }

  @override
  Future<String> submitBuyer({
    required Uint8List ktpBytes,
    required Uint8List npwpBytes,
  }) async {
    final ktpPath = await _uploadJpeg('ktp.jpg', ktpBytes);
    final npwpPath = await _uploadJpeg('npwp.jpg', npwpBytes);
    return _submit(ktpPath: ktpPath, npwpPath: npwpPath);
  }
}
