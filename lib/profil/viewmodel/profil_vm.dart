import 'package:agrimate/profil/model/profil.dart';
import 'package:agrimate/role_selection/model/role.dart';
import 'package:flutter/material.dart';

enum ProfileLoadState { loading, loaded, error }

class ProfileViewModel extends ChangeNotifier {
  final UserRole role;

  ProfileViewModel({required this.role}) {
    fetchProfile();
  }
  int _currentNavIndex = 4;
  int get currentNavIndex => _currentNavIndex;

  ProfileLoadState _state = ProfileLoadState.loading;
  ProfileLoadState get state => _state;

  ProfileModel? _profile;
  ProfileModel? get profile => _profile;

  bool _isLoggingOut = false;
  bool get isLoggingOut => _isLoggingOut;

  bool get isPetani => role == UserRole.petani;
  List<ProfileMenuItem> get menuItems => buildProfileMenu(role);

  Future<void> fetchProfile() async {
    _state = ProfileLoadState.loading;
    notifyListeners();

    try {

      await Future.delayed(const Duration(milliseconds: 500));

      _profile = ProfileModel(
        photoUrl: isPetani
            ? 'https://i.pravatar.cc/150?img=12' 
            : null,
        name: 'Septian Naruhodo',
        location: 'Malang, Jawa Timur',
        isVerified: true,
        rating: isPetani ? 5.0 : null,
      );

      _state = ProfileLoadState.loaded;
    } catch (e) {
      _state = ProfileLoadState.error;
    }
    notifyListeners();
  }

  void onEditProfilePressed(BuildContext context) {
    Navigator.pushNamed(context, '/edit-profile', arguments: role).then((result) {
      if (result is ProfileModel) {
        _profile = result;
        notifyListeners();
      }
    });
  }

  void onMenuItemPressed(BuildContext context, ProfileMenuItem item) {
    Navigator.pushNamed(context, item.route);
  }

void onNavTap(BuildContext context, int index) {
    if (index == _currentNavIndex) return;
    _currentNavIndex = index;
    notifyListeners();

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home-petani');
      case 1:
        Navigator.pushNamed(context, '/pasar');
        break;
      case 2:
        Navigator.pushNamed(context, '/rencana-panen');
        break;
      case 3:
        Navigator.pushNamed(context, '/transaksi');
        break;
      case 4:
        Navigator.pushNamed(context, '/profil');
        break;
    }
  }
  Future<void> onConfirmLogout(BuildContext context) async {
    _isLoggingOut = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    _isLoggingOut = false;
    notifyListeners();

    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, '/role', (route) => false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kamu berhasil keluar dari akun.'),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}