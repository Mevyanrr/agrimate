import 'dart:io';
import 'package:agrimate/backend/backend_dependencies.dart';
import 'package:agrimate/backend/core/constants/database_tables.dart';
import 'package:agrimate/backend/core/result/result.dart';
import 'package:agrimate/backend/features/profile/domain/entities/profile_entity.dart'
    as backend;
import 'package:agrimate/core/appcolor.dart';
import 'package:agrimate/role_selection/model/role.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/lengkapi_profil.dart';

enum SubmitState { idle, submitting, error }

class LengkapiProfilViewModel extends ChangeNotifier {
  LengkapiProfilViewModel({required this.role})
    : _backend = BackendDependencies.create() {
    for (final controller in [
      namaController,
      whatsappController,
      luasLahanController,
      alamatLahanController,
      nikController,
    ]) {
      controller.addListener(notifyListeners);
    }
  }

  final BackendDependencies _backend;
  final UserRole role;

  bool get isPembeli => role == UserRole.pembeli;

  Color get primaryColor =>
      isPembeli ? AppColors.orangeprimary : AppColors.greenprimary;

  Color get primaryLightColor =>
      isPembeli ? AppColors.lightorange : AppColors.lightgreen;

  final namaController = TextEditingController();
  final whatsappController = TextEditingController();
  final luasLahanController = TextEditingController();
  final alamatLahanController = TextEditingController();
  final nikController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  File? _fotoLahan;
  File? get fotoLahan => _fotoLahan;

  File? _fotoKtp;
  File? get fotoKtp => _fotoKtp;

  bool _submitAttempted = false;

  SubmitState _submitState = SubmitState.idle;
  SubmitState get submitState => _submitState;

  String? _submitError;
  String? get submitError => _submitError;

  static final _phoneRegex = RegExp(r'^0[0-9]{8,14}$');

  String? get namaError {
    final v = namaController.text.trim();
    if (v.isEmpty) return _submitAttempted ? 'Nama lengkap wajib diisi' : null;
    if (v.length < 3) return 'Nama minimal 3 karakter';
    return null;
  }

  String? get whatsappError {
    final v = whatsappController.text.trim();
    if (v.isEmpty)
      return _submitAttempted ? 'Nomor WhatsApp wajib diisi' : null;
    if (!_phoneRegex.hasMatch(v)) {
      return 'Format nomor tidak valid, contoh: 08512345678';
    }
    return null;
  }

  String? get luasLahanError {
    final v = luasLahanController.text.trim();
    if (v.isEmpty) return null;
    final parsed = double.tryParse(v.replaceAll(',', '.'));
    if (parsed == null || parsed <= 0) return 'Luas lahan tidak valid';
    return null;
  }

  String? get alamatLahanError {
    final v = alamatLahanController.text.trim();
    if (v.isEmpty) return _submitAttempted ? 'Alamat lahan wajib diisi' : null;
    if (v.length < 5) return 'Alamat terlalu pendek';
    return null;
  }

  String? get nikError {
    final v = nikController.text.trim();
    if (v.isEmpty) return _submitAttempted ? 'NIK KTP wajib diisi' : null;
    if (v.length != 16) return 'NIK harus 16 digit';
    return null;
  }

  bool get isFormValid {
    final nama = namaController.text.trim();
    final whatsapp = whatsappController.text.trim();
    final alamat = alamatLahanController.text.trim();
    final nik = nikController.text.trim();

    return nama.length >= 3 &&
        _phoneRegex.hasMatch(whatsapp) &&
        alamat.length >= 5 &&
        nik.length == 16 &&
        luasLahanError == null;
  }

  Future<void> pickFotoLahan() async {
    final file = await _pickImage();
    if (file != null) {
      _fotoLahan = file;
      notifyListeners();
    }
  }

  Future<void> pickFotoKtp() async {
    final file = await _pickImage();
    if (file != null) {
      _fotoKtp = file;
      notifyListeners();
    }
  }

  Future<File?> _pickImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      return picked != null ? File(picked.path) : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> submit(BuildContext context) async {
    _submitAttempted = true;
    notifyListeners();

    if (!isFormValid) return;

    _submitState = SubmitState.submitting;
    _submitError = null;
    notifyListeners();

    final payload = LengkapiProfilPayload(
      namaLengkap: namaController.text.trim(),
      nomorWhatsapp: whatsappController.text.trim(),
      luasLahanHektar: luasLahanController.text.trim().isEmpty
          ? null
          : double.tryParse(
              luasLahanController.text.trim().replaceAll(',', '.'),
            ),
      alamatLahan: alamatLahanController.text.trim(),
      nikKtp: nikController.text.trim(),
      fotoLahan: _fotoLahan,
      fotoKtp: _fotoKtp,
    );

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('Sesi login tidak ditemukan.');

      final existing = await _backend.profileRepository.getMine();
      if (existing case Failure(message: final message)) {
        throw Exception(message);
      }

      final profile = backend.ProfileEntity(
        id: userId,
        fullName: payload.namaLengkap,
        role: isPembeli ? backend.UserRole.buyer : backend.UserRole.farmer,
      );
      if (existing is! Success<backend.ProfileEntity?>) {
        throw Exception('Gagal membaca profil.');
      }
      final profileResult = existing.data == null
          ? await _backend.profileRepository.create(profile)
          : await _backend.profileRepository.updateMine(profile);
      if (profileResult case Failure(message: final message)) {
        throw Exception(message);
      }

      if (!isPembeli) {
        await Supabase.instance.client.from('farmer_details').upsert({
          'user_id': userId,
          'nik': payload.nikKtp,
          'land_area': payload.luasLahanHektar,
          'land_address': payload.alamatLahan,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        }, onConflict: 'user_id');
      }

      if (!isPembeli && payload.fotoLahan != null) {
        final extension = payload.fotoLahan!.path.split('.').last.toLowerCase();
        final contentType = extension == 'png' ? 'image/png' : 'image/jpeg';
        final landPhotoPath =
            '$userId/land_${DateTime.now().millisecondsSinceEpoch}.$extension';
        try {
          await Supabase.instance.client.storage
              .from(StorageBuckets.landPhotos)
              .uploadBinary(
                landPhotoPath,
                await payload.fotoLahan!.readAsBytes(),
                fileOptions: FileOptions(contentType: contentType),
              );
        } catch (error) {
          throw Exception('Upload foto lahan gagal: $error');
        }
        await Supabase.instance.client
            .from('farmer_details')
            .update({'land_photo_path': landPhotoPath})
            .eq('user_id', userId);
      }

      if (!isPembeli && payload.fotoKtp != null) {
        final ktpResult = await _backend.identityVerificationRepository
            .submitFarmer(
              ktpBytes: await payload.fotoKtp!.readAsBytes(),
              ktpFileName: payload.fotoKtp!.path.split('/').last,
            );
        if (ktpResult case Failure(message: final message)) {
          throw Exception('Upload foto KTP gagal: $message');
        }
      }

      _submitState = SubmitState.idle;
      notifyListeners();

      if (context.mounted) {
        Navigator.pushReplacementNamed(
          context,
          isPembeli ? '/home-pembeli' : '/home-petani',
        );
      }
    } catch (e) {
      _submitState = SubmitState.error;
      _submitError = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  @override
  void dispose() {
    namaController.dispose();
    whatsappController.dispose();
    luasLahanController.dispose();
    alamatLahanController.dispose();
    nikController.dispose();
    super.dispose();
  }
}
