enum UserRole { farmer, buyer }

class ProfileEntity {
  const ProfileEntity({
    required this.id,
    required this.fullName,
    required this.role,
    this.businessName,
    this.photoUrl,
    this.address,
    this.province,
    this.city,
    this.district,
    this.phone,
  });

  final String id;
  final String fullName;
  final UserRole role;
  final String? businessName;
  final String? photoUrl;
  final String? address;
  final String? province;
  final String? city;
  final String? district;
  final String? phone;
}
