class IdentityVerification {
  const IdentityVerification({
    required this.id,
    required this.userId,
    required this.ktpPath,
    this.npwpPath,
    required this.submittedAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String ktpPath;
  final String? npwpPath;
  final DateTime submittedAt;
  final DateTime updatedAt;

  bool isComplete({required bool requiresNpwp}) =>
      ktpPath.isNotEmpty && (!requiresNpwp || (npwpPath?.isNotEmpty ?? false));
}
