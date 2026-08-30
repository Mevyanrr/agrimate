import '../../domain/entities/identity_verification.dart';

class IdentityVerificationModel extends IdentityVerification {
  const IdentityVerificationModel({
    required super.id,
    required super.userId,
    required super.ktpPath,
    super.npwpPath,
    required super.status,
    super.rejectionReason,
    required super.submittedAt,
    super.verifiedAt,
    required super.updatedAt,
  });

  factory IdentityVerificationModel.fromJson(Map<String, dynamic> json) {
    return IdentityVerificationModel(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      ktpPath: json['ktp_path'] as String,
      npwpPath: json['npwp_path'] as String?,
      status: _statusFromJson(json['verification_status'] as String),
      rejectionReason: json['rejection_reason'] as String?,
      submittedAt: DateTime.parse(json['submitted_at'] as String),
      verifiedAt: json['verified_at'] == null
          ? null
          : DateTime.parse(json['verified_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  static VerificationStatus _statusFromJson(String value) => switch (value) {
    'PENDING' => VerificationStatus.pending,
    'VERIFIED' => VerificationStatus.verified,
    'REJECTED' => VerificationStatus.rejected,
    _ => throw FormatException('Status verifikasi tidak dikenal: $value'),
  };
}
