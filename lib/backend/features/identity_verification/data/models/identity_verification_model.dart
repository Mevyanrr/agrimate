import '../../domain/entities/identity_verification.dart';

class IdentityVerificationModel extends IdentityVerification {
  const IdentityVerificationModel({
    required super.id,
    required super.userId,
    required super.ktpPath,
    super.npwpPath,
    required super.submittedAt,
    required super.updatedAt,
  });

  factory IdentityVerificationModel.fromJson(Map<String, dynamic> json) {
    return IdentityVerificationModel(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      ktpPath: json['ktp_path'] as String,
      npwpPath: json['npwp_path'] as String?,
      submittedAt: DateTime.parse(json['submitted_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
