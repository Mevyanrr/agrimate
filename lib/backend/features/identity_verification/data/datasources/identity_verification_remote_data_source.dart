import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/database_tables.dart';
import '../../../../core/errors/backend_exception.dart';
import '../models/identity_verification_model.dart';

abstract interface class IdentityVerificationRemoteDataSource {
  Future<IdentityVerificationModel?> getMine();
  Future<String> submitFarmer({
    required Uint8List ktpBytes,
    required String ktpFileName,
  });
  Future<String> submitBuyer({
    required Uint8List ktpBytes,
    required String ktpFileName,
    required Uint8List npwpBytes,
    required String npwpFileName,
  });
}

class SupabaseIdentityVerificationRemoteDataSource
    implements IdentityVerificationRemoteDataSource {
  const SupabaseIdentityVerificationRemoteDataSource(this._client);

  final SupabaseClient _client;

  String get _userId =>
      _client.auth.currentUser?.id ??
      (throw const BackendException(
        'Pengguna belum login.',
        code: 'unauthenticated',
      ));

  @override
  Future<IdentityVerificationModel?> getMine() async {
    final row = await _client
        .from(DatabaseTables.identityDocuments)
        .select()
        .eq('user_id', _userId)
        .maybeSingle();

    return row == null ? null : IdentityVerificationModel.fromJson(row);
  }

  Future<String> _uploadDocument(
    String documentName,
    String originalFileName,
    Uint8List bytes,
  ) async {
    if (bytes.isEmpty) {
      throw const BackendException('File dokumen tidak boleh kosong.');
    }

    final extension = originalFileName.split('.').last.toLowerCase();
    const allowedExtensions = {'jpg', 'jpeg', 'png', 'pdf'};
    if (!allowedExtensions.contains(extension)) {
      throw const BackendException('Dokumen harus berupa JPG, PNG, atau PDF.');
    }
    final contentType = switch (extension) {
      'png' => 'image/png',
      'pdf' => 'application/pdf',
      _ => 'image/jpeg',
    };
    final path = '$_userId/$documentName.$extension';
    await _client.storage
        .from(StorageBuckets.identityDocuments)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: contentType,
          ),
        );
    return path;
  }

  Future<String> _submit({required String ktpPath, String? npwpPath}) async {
    final row = await _client
        .from(DatabaseTables.identityDocuments)
        .upsert({
          'user_id': _userId,
          'ktp_path': ktpPath,
          'npwp_path': npwpPath,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        }, onConflict: 'user_id')
        .select('id')
        .single();
    return row['id'].toString();
  }

  @override
  Future<String> submitFarmer({
    required Uint8List ktpBytes,
    required String ktpFileName,
  }) async {
    final ktpPath = await _uploadDocument('ktp', ktpFileName, ktpBytes);
    return _submit(ktpPath: ktpPath);
  }

  @override
  Future<String> submitBuyer({
    required Uint8List ktpBytes,
    required String ktpFileName,
    required Uint8List npwpBytes,
    required String npwpFileName,
  }) async {
    final ktpPath = await _uploadDocument('ktp', ktpFileName, ktpBytes);
    final npwpPath = await _uploadDocument('npwp', npwpFileName, npwpBytes);
    return _submit(ktpPath: ktpPath, npwpPath: npwpPath);
  }
}
