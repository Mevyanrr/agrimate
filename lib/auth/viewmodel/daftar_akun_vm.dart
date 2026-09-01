import 'package:agrimate/auth/model/daftar_akun.dart';
import 'package:agrimate/auth/model/otp.dart';
import 'package:agrimate/auth/view/otp_sheet.dart';
import 'package:agrimate/backend/backend_dependencies.dart';
import 'package:agrimate/backend/core/errors/backend_exception.dart';
import 'package:agrimate/backend/features/auth/domain/entities/auth_registration.dart';
import 'package:agrimate/core/appcolor.dart';
import 'package:agrimate/role_selection/model/role.dart';
import 'package:flutter/material.dart';

class RegisterViewModel extends ChangeNotifier {
  final UserRole role;
  late final _authRepository = BackendDependencies.create().authRepository;

  RegisterViewModel({required this.role});

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

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

    final method = await showOtpMethodSheet(
      context,
      phoneNumber: phoneController.text.trim(),
      accentColor: accentColor,
      accentColorLight: accentColorLight,
    );
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

    try {
      final result = await _authRepository.register(
        AuthRegistration(
          phone: request.phoneNumber,
          password: request.password,
          email: request.email,
          role: isPetani ? AuthUserRole.farmer : AuthUserRole.buyer,
          channel: method == OtpMethod.whatsapp
              ? AuthOtpChannel.whatsapp
              : AuthOtpChannel.sms,
        ),
      );
      if (!context.mounted) return;
      if (result.requiresOtp) {
        Navigator.pushNamed(
          context,
          '/otp-verification',
          arguments: {
            'role': role,
            'phoneNumber': request.phoneNumber,
            'method': method,
          },
        );
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          isPetani ? '/home-petani' : '/home-pembeli',
          (route) => false,
        );
      }
    } on BackendException catch (error) {
      if (context.mounted) _showError(context, error.message);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
