enum UserRole { farmer, buyer }

class ProfileEntity {
  const ProfileEntity({
    required this.id,
    required this.fullName,
    required this.role,
    this.businessName,
    this.photoUrl,
  });

  final String id;
  final String fullName;
  final UserRole role;
  final String? businessName;
  final String? photoUrl;
}
