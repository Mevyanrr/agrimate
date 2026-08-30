import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.fullName,
    required super.role,
    super.businessName,
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
    );
  }

  Map<String, dynamic> toCreateJson() => {
    'id': id,
    'full_name': fullName,
    'role': role == UserRole.farmer ? 'FARMER' : 'BUYER',
    'business_name': businessName,
  };

  /// Role dan ID sengaja tidak dapat diubah dari update profile biasa.
  Map<String, dynamic> toEditableJson() => {
    'full_name': fullName,
    'business_name': businessName,
  };
}
