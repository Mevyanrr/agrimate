import 'dart:async';

import 'package:agrimate/backend/backend_dependencies.dart';
import 'package:agrimate/backend/core/result/result.dart';
import 'package:agrimate/backend/features/profile/domain/entities/profile_entity.dart'
    as backend;
import 'package:agrimate/role_selection/model/role.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashViewModel extends ChangeNotifier {
  Timer? _timer;

  void startTimer({
    required BuildContext context,
    required Duration duration,
    required String nextRoute,
  }) {
    _timer?.cancel();
    _timer = Timer(duration, () {
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, nextRoute);
      }
    });
  }

  Future<void> resolveInitialRoute({
    required BuildContext context,
    Duration minimumDuration = const Duration(seconds: 2),
  }) async {
    await Future<void>.delayed(minimumDuration);
    if (!context.mounted) return;

    final client = Supabase.instance.client;
    final session = client.auth.currentSession;
    if (session == null) {
      _replaceAll(context, '/onboarding');
      return;
    }

    // currentSession hanya membaca token cache perangkat. getUser memvalidasi
    // token itu ke server sehingga akun Auth yang sudah dihapus bisa terdeteksi.
    try {
      final remoteUser = (await client.auth.getUser()).user;
      if (remoteUser == null) {
        if (!context.mounted) return;
        await _clearDeletedSession(client, context);
        return;
      }
    } on AuthException {
      if (!context.mounted) return;
      await _clearDeletedSession(client, context);
      return;
    }

    final profileResult = await BackendDependencies.create().profileRepository
        .getMine();
    if (!context.mounted) return;

    switch (profileResult) {
      case Success(data: final profile?):
        final incomplete =
            profile.fullName.trim().isEmpty ||
            (profile.address?.trim().isEmpty ?? true) ||
            (profile.province?.trim().isEmpty ?? true);
        if (incomplete) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/lengkapi-profil',
            (route) => false,
            arguments: {
              'role': profile.role == backend.UserRole.buyer
                  ? UserRole.pembeli
                  : UserRole.petani,
            },
          );
        } else {
          _replaceAll(
            context,
            profile.role == backend.UserRole.buyer
                ? '/home-pembeli'
                : '/home-petani',
          );
        }
      case Success(data: null):
        // Registrasi/OTP selalu membuat profile awal. Profile yang benar-benar
        // hilang menandakan data akun sudah dihapus, bukan profile belum lengkap.
        await _clearDeletedSession(client, context);
      case Failure():
        // Session lokal tetap dipakai saat profile sementara gagal dimuat.
        _replaceAll(context, _routeFromMetadata(client.auth.currentUser));
    }
  }

  Future<void> _clearDeletedSession(
    SupabaseClient client,
    BuildContext context,
  ) async {
    await client.auth.signOut(scope: SignOutScope.local);
    if (context.mounted) _replaceAll(context, '/onboarding');
  }

  String _routeFromMetadata(User? user) {
    final role = user?.userMetadata?['role']?.toString().toUpperCase();
    return role == 'BUYER' ? '/home-pembeli' : '/home-petani';
  }

  void _replaceAll(BuildContext context, String route) {
    Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
