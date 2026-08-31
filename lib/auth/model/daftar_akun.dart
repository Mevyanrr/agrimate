class RegisterRequestModel {
  final String? email; 
  final String phoneNumber;
  final String password;
  final String confirmPassword;

  const RegisterRequestModel({
    this.email,
    required this.phoneNumber,
    required this.password,
    required this.confirmPassword,
  });
}

class RegisterValidator {
  RegisterValidator._();

  static final RegExp _emailRegex =
      RegExp(r'^[\w.\-]+@([\w\-]+\.)+[\w\-]{2,}$');
  static final RegExp _phoneRegex = RegExp(r'^(\+62|62|0)8[0-9]{8,12}$');

  static String? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    if (!_emailRegex.hasMatch(trimmed)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  static String? phoneNumber(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Nomor WhatsApp wajib diisi';
    }
    if (!_phoneRegex.hasMatch(trimmed)) {
      return 'Masukkan nomor WhatsApp yang valid';
    }
    return null;
  }

  static String? password(String? value) {
    final trimmed = value ?? '';
    if (trimmed.isEmpty) {
      return 'Password wajib diisi';
    }
    if (trimmed.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    final trimmed = value ?? '';
    if (trimmed.isEmpty) {
      return 'Ulangi password wajib diisi';
    }
    if (trimmed != password) {
      return 'Password tidak sama';
    }
    return null;
  }
}