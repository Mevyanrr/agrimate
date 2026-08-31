class LoginRequestModel {
  final String identifier; 
  final String password;

  const LoginRequestModel({
    required this.identifier,
    required this.password,
  });
}
class LoginValidator {
  LoginValidator._();

  static final RegExp _emailRegex =
      RegExp(r'^[\w.\-]+@([\w\-]+\.)+[\w\-]{2,}$');
  static final RegExp _phoneRegex = RegExp(r'^(\+62|62|0)8[0-9]{8,12}$');

  static String? identifier(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Nomor WhatsApp / Email wajib diisi';
    }
    final isEmail = _emailRegex.hasMatch(trimmed);
    final isPhone = _phoneRegex.hasMatch(trimmed);
    if (!isEmail && !isPhone) {
      return 'Masukkan email atau nomor WhatsApp yang valid';
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
}