import 'package:agrimate/auth/model/daftar_akun.dart';
import 'package:agrimate/auth/model/otp.dart';
import 'package:agrimate/auth/view/otp_sheet.dart';
import 'package:agrimate/core/appcolor.dart';
import 'package:agrimate/role_selection/model/role.dart';
import 'package:flutter/material.dart';

class RegisterViewModel extends ChangeNotifier {
  final UserRole role;

  RegisterViewModel({required this.role});

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  bool _obscureConfirmPassword = true;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool get isPetani => role == UserRole.petani;
  String get roleLabel => isPetani ? 'Petani' : 'Pembeli';
  Color get accentColor =>
      isPetani ? AppColors.greenprimary : AppColors.orangeprimary;
  Color get accentColorLight =>
      isPetani ? AppColors.lightgreen : AppColors.lightorange;

  String? validateEmail(String? value) => RegisterValidator.email(value);
  String? validatePhone(String? value) => RegisterValidator.phoneNumber(value);
  String? validatePassword(String? value) => RegisterValidator.password(value);
  String? validateConfirmPassword(String? value) =>
      RegisterValidator.confirmPassword(value, passwordController.text);

  Future<void> onSubmitPressed(BuildContext context) async {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final method = await showOtpMethodSheet(context, accentColor: accentColor, accentColorLight: accentColorLight);
    if (method == null) return;
    if (!context.mounted) return;

    await _sendOtp(context, method);
  }

  Future<void> _sendOtp(BuildContext context, OtpMethod method) async {
    _isLoading = true;
    notifyListeners();

    final request = RegisterRequestModel(
      email: emailController.text.trim().isEmpty
          ? null
          : emailController.text.trim(),
      phoneNumber: phoneController.text.trim(),
      password: passwordController.text,
      confirmPassword: confirmPasswordController.text,
    );

    await Future.delayed(const Duration(milliseconds: 800));
    debugPrint(
        'Kirim OTP via ${method.name} ke ${request.phoneNumber} (role: $roleLabel)');

    _isLoading = false;
    notifyListeners();

    if (!context.mounted) return;
    Navigator.pushNamed(
      context,
      '/otp-verification',
      arguments: {
        'role': role,
        'phoneNumber': request.phoneNumber,
        'method': method,
      },
    );
  }

  void onLoginHerePressed(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/login', arguments: role);
  }

  void onBackPressed(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}