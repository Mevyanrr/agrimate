import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.fullName,
    required super.role,
    super.businessName,
    super.photoUrl,
    super.address,
    super.province,
    super.city,
    super.district,
    super.phone,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'].toString(),
      fullName: json['full_name'] as String,
      role: switch (json['role'] as String) {
        'FARMER' => UserRole.farmer,
        'BUYER' => UserRole.buyer,
        final value => throw FormatException('Role tidak dikenal: $value'),
      },
      businessName: json['business_name'] as String?,
      photoUrl: json['photo_url'] as String?,
      address: json['address'] as String?,
      province: json['province'] as String?,
      city: json['city'] as String?,
      district: json['district'] as String?,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toCreateJson() => {
    'id': id,
    'full_name': fullName,
    'role': role == UserRole.farmer ? 'FARMER' : 'BUYER',
    'business_name': businessName,
    'photo_url': photoUrl,
    'address': address,
    'province': province,
    'city': city,
    'district': district,
    'phone': phone,
  };

  /// Role dan ID sengaja tidak dapat diubah dari update profile biasa.
  Map<String, dynamic> toEditableJson() => {
    'full_name': fullName,
    'business_name': businessName,
    'photo_url': photoUrl,
    if (address != null) 'address': address,
    if (province != null) 'province': province,
    if (city != null) 'city': city,
    if (district != null) 'district': district,
    if (phone != null) 'phone': phone,
  };
}
