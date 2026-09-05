import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/backend_exception.dart';
import '../domain/entities/auth_registration.dart';
import '../domain/repositories/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  const SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  static String normalizeIndonesianPhone(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.startsWith('+62')) return digits;
    if (digits.startsWith('62')) return '+$digits';
    if (digits.startsWith('0')) return '+62${digits.substring(1)}';
    return digits.startsWith('+') ? digits : '+$digits';
  }

  OtpChannel _channel(AuthOtpChannel channel) =>
      channel == AuthOtpChannel.whatsapp ? OtpChannel.whatsapp : OtpChannel.sms;

  String _roleValue(AuthUserRole role) =>
      role == AuthUserRole.farmer ? 'FARMER' : 'BUYER';

  AuthUserRole _roleFromValue(String value) => switch (value) {
    'FARMER' => AuthUserRole.farmer,
    'BUYER' => AuthUserRole.buyer,
    _ => throw const BackendException(
      'Peran pengguna tidak valid.',
      code: 'invalid_role',
    ),
  };

  Future<void> _ensureProfile(User user) async {
    final role = user.userMetadata?['role'] as String?;
    if (role == null || (role != 'FARMER' && role != 'BUYER')) {
      throw const BackendException(
        'Peran pengguna tidak ditemukan.',
        code: 'missing_role',
      );
    }

    final metadataName =
        user.userMetadata?['full_name'] ?? user.userMetadata?['name'];

    await _client
        .from('profiles')
        .upsert(
          {
            'id': user.id,
            'full_name': metadataName is String ? metadataName : '',
            'role': role,
          },
          onConflict: 'id',
          ignoreDuplicates: true,
        );
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AuthException catch (error) {
      throw BackendException(
        _friendlyMessage(error),
        code: error.code ?? 'auth_error',
      );
    } catch (error) {
      if (error is BackendException) rethrow;
      throw BackendException('Koneksi ke server gagal: $error');
    }
  }

  String _friendlyMessage(AuthException error) {
    final message = error.message.toLowerCase();
    if (message.contains('invalid login credentials')) {
      return 'Email/nomor WhatsApp atau password salah.';
    }
    if (message.contains('already registered') ||
        message.contains('already been registered')) {
      return 'Nomor WhatsApp tersebut sudah terdaftar.';
    }
    if (message.contains('rate limit') || message.contains('too many')) {
      return 'Terlalu banyak percobaan. Coba lagi beberapa saat.';
    }
    if (message.contains('token') &&
        (message.contains('invalid') || message.contains('expired'))) {
      return 'Kode OTP salah atau sudah kedaluwarsa.';
    }
    return error.message;
  }

  @override
  Future<AuthRegistrationResult> register(AuthRegistration registration) =>
      _guard(() async {
        final response = await _client.auth.signUp(
          phone: normalizeIndonesianPhone(registration.phone),
          password: registration.password,
          channel: _channel(registration.channel),
          data: {
            'role': _roleValue(registration.role),
            'email_contact': ?registration.email,
          },
        );
        if (response.session != null && response.user != null) {
          await _ensureProfile(response.user!);
        }
        return AuthRegistrationResult(requiresOtp: response.session == null);
      });

  @override
  Future<void> verifyPhoneOtp({required String phone, required String token}) =>
      _guard(() async {
        final response = await _client.auth.verifyOTP(
          phone: normalizeIndonesianPhone(phone),
          token: token,
          type: OtpType.sms,
        );
        final contactEmail =
            response.user?.userMetadata?['email_contact'] as String?;
        if (contactEmail != null && contactEmail.isNotEmpty) {
          final response = await _client.functions.invoke(
            'confirm-registration-email',
          );

          if (response.status != 200) {
            final data = response.data;
            final message = data is Map ? data['error']?.toString() : null;

            throw BackendException(
              message ?? 'Gagal mengaktifkan email.',
              code: 'email_activation_failed',
            );
          }
        }
        if (response.user != null) {
          await _ensureProfile(response.user!);
        }
      });

  @override
  Future<void> resendPhoneOtp({
    required String phone,
    required AuthOtpChannel channel,
  }) => _guard(() async {
    await _client.auth.signInWithOtp(
      phone: normalizeIndonesianPhone(phone),
      shouldCreateUser: false,
      channel: _channel(channel),
    );
  });

  @override
  Future<void> login({
    required String identifier,
    required String password,
    required AuthUserRole expectedRole,
  }) => _guard(() async {
    final value = identifier.trim();
    final isEmail = value.contains('@');
    final response = await _client.auth.signInWithPassword(
      email: isEmail ? value : null,
      phone: isEmail ? null : normalizeIndonesianPhone(value),
      password: password,
    );
    final actualRole = response.user?.userMetadata?['role'] as String?;
    if (actualRole != null && actualRole != _roleValue(expectedRole)) {
      await _client.auth.signOut();
      throw const BackendException(
        'Akun ini terdaftar dengan peran yang berbeda.',
        code: 'role_mismatch',
      );
    }
  });

  @override
  Future<void> loginWithGoogle() => _guard(() async {
    final opened = await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb ? null : 'agrimate://login-callback',
    );
    if (!opened) {
      throw const BackendException('Tidak dapat membuka login Google.');
    }
  });

  @override
  Future<void> loginWithFacebook() => _guard(() async {
    final opened = await _client.auth.signInWithOAuth(
      OAuthProvider.facebook,
      // Selalu kembalikan OAuth Facebook ke aplikasi. Jika nilai ini null,
      // Supabase memakai Site URL (mis. http://localhost:3000) sebagai fallback.
      redirectTo: 'agrimate://login-callback',
      scopes: 'email,public_profile',
    );
    if (!opened) {
      throw const BackendException('Tidak dapat membuka login Facebook.');
    }
  });

  @override
  Future<AuthUserRole> completeSocialLogin({
    required AuthUserRole expectedRole,
  }) => _guard(() async {
    var user = _client.auth.currentUser;
    if (user == null) {
      throw const BackendException(
        'Sesi login sosial tidak ditemukan.',
        code: 'unauthenticated',
      );
    }

    final profile = await _client
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .maybeSingle();
    final profileRole = profile?['role'] as String?;
    final metadataRole = user.userMetadata?['role'] as String?;
    final storedRole = profileRole ?? metadataRole;
    final resolvedRole = storedRole == null
        ? expectedRole
        : _roleFromValue(storedRole);
    final resolvedRoleValue = _roleValue(resolvedRole);

    // Pilihan role pada layar login hanya dipakai untuk akun OAuth baru.
    // Akun lama selalu mengikuti role yang sudah tersimpan di profile.
    if (metadataRole != resolvedRoleValue) {
      final response = await _client.auth.updateUser(
        UserAttributes(data: {'role': resolvedRoleValue}),
      );
      user = response.user ?? user;
    }

    await _ensureProfile(user);
    return resolvedRole;
  });

  @override
  Future<void> signOut() => _guard(_client.auth.signOut);
}
