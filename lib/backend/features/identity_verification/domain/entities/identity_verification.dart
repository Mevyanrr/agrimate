enum VerificationStatus { pending, verified, rejected }

class IdentityVerification {
  const IdentityVerification({
    required this.id,
    required this.userId,
    required this.ktpPath,
    this.npwpPath,
    required this.status,
    this.rejectionReason,
    required this.submittedAt,
    this.verifiedAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String ktpPath;
  final String? npwpPath;
  final VerificationStatus status;
  final String? rejectionReason;
  final DateTime submittedAt;
  final DateTime? verifiedAt;
  final DateTime updatedAt;
}
