import 'package:agrimate/backend/backend_dependencies.dart';
import 'package:agrimate/backend/core/result/result.dart';
import 'package:agrimate/backend/features/profile/domain/entities/profile_entity.dart'
    as backend;
import 'package:agrimate/profil/model/profil.dart';
import 'package:agrimate/role_selection/model/role.dart';
import 'package:flutter/material.dart';

enum ProfileLoadState { loading, loaded, error }

class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel({required this.role}) {
    fetchProfile();
  }

  final UserRole role;
  final BackendDependencies _backend = BackendDependencies.create();

  int get currentNavIndex => 4;

  ProfileLoadState _state = ProfileLoadState.loading;
  ProfileLoadState get state => _state;

  ProfileModel? _profile;
  ProfileModel? get profile => _profile;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isLoggingOut = false;
  bool get isLoggingOut => _isLoggingOut;

  bool get isPetani => role == UserRole.petani;
  List<ProfileMenuItem> get menuItems => buildProfileMenu(role);

  Future<void> fetchProfile() async {
    _state = ProfileLoadState.loading;
    notifyListeners();

    final result = await _backend.profileRepository.getMine();
    switch (result) {
      case Success(data: final value?):
        final verificationResult = await _backend.identityVerificationRepository
            .getMine();
        final isVerified = switch (verificationResult) {
          Success(data: final verification?) => verification.isComplete(
            requiresNpwp: !isPetani,
          ),
          _ => false,
        };
        _profile = ProfileModel(
          photoUrl: value.photoUrl,
          name: value.fullName,
          location:
              value.businessName ??
              (isPetani ? 'Usaha tani belum diisi' : 'Usaha belum diisi'),
          isVerified: isVerified,
        );
        _errorMessage = null;
        _state = ProfileLoadState.loaded;
      case Success(data: null):
        _errorMessage = 'Profil belum tersedia.';
        _state = ProfileLoadState.error;
      case Failure(message: final message):
        _errorMessage = message;
        _state = ProfileLoadState.error;
    }
    notifyListeners();
  }

  Future<void> onEditProfilePressed(BuildContext context) async {
    final current = _profile;
    if (current == null) return;

    final result = await Navigator.pushNamed(
      context,
      '/edit-profile',
      arguments: {'role': role, 'profile': current},
    );
    if (result is! ProfileEditResult) return;

    _state = ProfileLoadState.loading;
    notifyListeners();

    var photoUrl = result.profile.photoUrl;
    if (result.photoBytes != null && result.photoFileName != null) {
      final uploadResult = await _backend.profileRepository.uploadPhoto(
        bytes: result.photoBytes!,
        fileName: result.photoFileName!,
      );
      switch (uploadResult) {
        case Success(data: final url):
          photoUrl = url;
        case Failure(message: final message):
          _state = ProfileLoadState.loaded;
          notifyListeners();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal mengunggah foto: $message')),
            );
          }
          return;
      }
    }

    final backendResult = await _backend.profileRepository.updateMine(
      backend.ProfileEntity(
        id: '',
        fullName: result.profile.name,
        role: isPetani ? backend.UserRole.farmer : backend.UserRole.buyer,
        businessName: result.profile.location,
        photoUrl: photoUrl,
      ),
    );

    switch (backendResult) {
      case Success(data: final value):
        _profile = result.profile.copyWith(
          photoUrl: value.photoUrl,
          name: value.fullName,
          location: value.businessName ?? result.profile.location,
        );
        _errorMessage = null;
        _state = ProfileLoadState.loaded;
      case Failure(message: final message):
        _errorMessage = message;
        _state = ProfileLoadState.loaded;
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menyimpan profil: $message')),
          );
        }
    }
    notifyListeners();
  }

  void onMenuItemPressed(BuildContext context, ProfileMenuItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur ini masih dalam pengembangan.')),
    );
  }

  void onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(
          context,
          isPetani ? '/home-petani' : '/home-pembeli',
        );
        break;
      case 1:
        if (isPetani) Navigator.pushReplacementNamed(context, '/pasar');
        break;
      case 2:
        if (isPetani) Navigator.pushReplacementNamed(context, '/rencana-panen');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/transaksi', arguments: role);
        break;
      case 4:
        break;
    }
  }

  Future<void> onConfirmLogout(BuildContext context) async {
    _isLoggingOut = true;
    notifyListeners();

    try {
      await _backend.authRepository.signOut();
      _isLoggingOut = false;
      notifyListeners();
      if (!context.mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/role-selection',
        (route) => false,
      );
    } catch (error) {
      _isLoggingOut = false;
      notifyListeners();
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal keluar: $error')));
    }
  }
}
