import 'dart:async';

import 'package:agrimate/backend/backend_dependencies.dart';
import 'package:agrimate/backend/core/result/result.dart';
import 'package:agrimate/backend/features/profile/domain/entities/profile_entity.dart'
    as backend;
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

    final profileResult = await BackendDependencies.create().profileRepository
        .getMine();
    if (!context.mounted) return;

    switch (profileResult) {
      case Success(data: final profile?):
        final route = switch (profile.role) {
          backend.UserRole.buyer => '/home-pembeli',
          backend.UserRole.farmer when profile.fullName.trim().isNotEmpty =>
            '/home-petani',
          backend.UserRole.farmer => '/lengkapi-profil',
        };
        _replaceAll(context, route);
      case Success(data: null):
        _replaceAll(context, _routeFromMetadata(client.auth.currentUser));
      case Failure():
        // Session lokal tetap dipakai saat profile sementara gagal dimuat.
        _replaceAll(context, _routeFromMetadata(client.auth.currentUser));
    }
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
