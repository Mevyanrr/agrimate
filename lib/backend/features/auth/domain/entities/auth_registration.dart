enum AuthUserRole { farmer, buyer }

enum AuthOtpChannel { sms, whatsapp }

class AuthRegistration {
  const AuthRegistration({
    required this.phone,
    required this.password,
    required this.role,
    required this.channel,
    this.email,
  });

  final String phone;
  final String password;
  final AuthUserRole role;
  final AuthOtpChannel channel;
  final String? email;
}

class AuthRegistrationResult {
  const AuthRegistrationResult({required this.requiresOtp});

  final bool requiresOtp;
}
