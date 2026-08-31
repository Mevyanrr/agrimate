import 'package:agrimate/core/appcolor.dart';
import 'package:agrimate/role_selection/model/role.dart';
import 'package:flutter/material.dart';


class RoleViewModel extends ChangeNotifier {
  final List<RoleModel> roles = const [
    RoleModel(
      id: UserRole.petani,
      iconPath: 'assets/icons/tea.svg',
      title: 'Saya Petani',
      description:
          'Isi rencana panen, kami akan membantu mencarikan pembeli yang cocok',
      accentColor: AppColors.greenprimary,
      accentColorLight: AppColors.lightgreen,
    ),
    RoleModel(
      id: UserRole.pembeli,
      iconPath: 'assets/icons/store.svg',
      title: 'Saya Pembeli',
      description:
          'Pemilik restoran, distributor, atau catering yang membutuhkan pasokan rutin',
      accentColor: AppColors.orangeprimary,
      accentColorLight: AppColors.lightorange,
    ),
  ];

  UserRole _selectedRole = UserRole.petani;
  UserRole get selectedRole => _selectedRole;

  Color get activeColor => _selectedRole == UserRole.petani
      ? AppColors.greenprimary
      : AppColors.orangeprimary;

  void selectRole(UserRole role) {
    if (_selectedRole == role) return; 
    _selectedRole = role;
    notifyListeners();
  }

  bool isSelected(UserRole role) => _selectedRole == role;

  void onNextPressed(BuildContext context) {
    final nextRoute =
        _selectedRole == UserRole.petani ? '/home-petani' : '/home-pembeli';
    Navigator.pushReplacementNamed(context, nextRoute);
  }
}