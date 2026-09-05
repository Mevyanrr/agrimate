import '../entities/auth_registration.dart';

abstract interface class AuthRepository {
  Future<AuthRegistrationResult> register(AuthRegistration registration);

  Future<void> verifyPhoneOtp({required String phone, required String token});

  Future<void> resendPhoneOtp({
    required String phone,
    required AuthOtpChannel channel,
  });

  Future<void> login({
    required String identifier,
    required String password,
    required AuthUserRole expectedRole,
  });

  Future<void> loginWithGoogle();

  Future<void> loginWithFacebook();

  /// Menyelesaikan onboarding OAuth dan mengembalikan role akun yang tersimpan.
  Future<AuthUserRole> completeSocialLogin({
    required AuthUserRole expectedRole,
  });

  Future<void> signOut();
}
