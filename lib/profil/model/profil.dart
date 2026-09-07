import 'package:agrimate/role_selection/model/role.dart';

class ProfileModel {
  final String? photoUrl;
  final String name;
  final String location;
  final bool isVerified;
  final double? rating;

  const ProfileModel({
    this.photoUrl,
    required this.name,
    required this.location,
    required this.isVerified,
    this.rating,
  });

  ProfileModel copyWith({
    String? photoUrl,
    String? name,
    String? location,
  }) {
    return ProfileModel(
      photoUrl: photoUrl ?? this.photoUrl,
      name: name ?? this.name,
      location: location ?? this.location,
      isVerified: isVerified,
      rating: rating,
    );
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      photoUrl: json['photo_url'] as String?,
      name: json['name'] as String? ?? '-',
      location: json['location'] as String? ?? '-',
      isVerified: json['is_verified'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble(),
    );
  }
}

class ProfileMenuItem {
  final String iconPath; // Menggantikan iconEmoji
  final String title;
  final String description;
  final String route;

  const ProfileMenuItem({
    required this.iconPath,
    required this.title,
    required this.description,
    required this.route,
  });
}

List<ProfileMenuItem> buildProfileMenu(UserRole role) {
  final isPetani = role == UserRole.petani;
  return [
    ProfileMenuItem(
      iconPath: 'assets/images/laporan_penjualan.png',
      title: isPetani ? 'Laporan Penjualan' : 'Laporan Pembelian',
      description: isPetani
          ? 'Lihat laporan penjualanmu di sini'
          : 'Lihat laporan pembelian di sini',
      route: '/laporan',
    ),
    const ProfileMenuItem(
      iconPath: 'assets/images/Tomat.png',
      title: 'Informasi Pribadi',
      description:
          'Perbarui informasi tentang data diri, alamat, rekening, hingga detail usahamu',
      route: '/informasi-pribadi',
    ),
    const ProfileMenuItem(
      iconPath: 'assets/images/notif.png',
      title: 'Pengaturan Notifikasi',
      description: 'Atur bagaimana kamu ingin diberitahu',
      route: '/pengaturan-notifikasi',
    ),
    const ProfileMenuItem(
      iconPath: 'assets/images/keamanan.png',
      title: 'Verifikasi dan Keamanan Akun',
      description: 'Ubah Password dan Perbarui Keamanan Akun',
      route: '/keamanan-akun',
    ),
    const ProfileMenuItem(
      iconPath: 'assets/images/help.png',
      title: 'Bantuan dan Tutorial Ulang',
      description: 'Lihat kembali panduan penggunaan aplikasi',
      route: '/bantuan',
    ),
    const ProfileMenuItem(
      iconPath: 'assets/images/cs.png',
      title: 'Hubungi Kami',
      description: 'Hubungi layanan kami jika ada kendala',
      route: '/hubungi-kami',
    ),
  ];
}