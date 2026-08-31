import 'package:agrimate/auth/model/masuk.dart';
import 'package:agrimate/core/appcolor.dart';
import 'package:agrimate/role_selection/model/role.dart';
import 'package:flutter/material.dart';

class LoginViewModel extends ChangeNotifier {
  final UserRole role;

  LoginViewModel({required this.role});

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController identifierController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool get isPetani => role == UserRole.petani;
  String get roleLabel => isPetani ? 'Petani' : 'Pembeli';
  Color get accentColor =>
      isPetani ? AppColors.greenprimary : AppColors.orangeprimary;

  String? validateIdentifier(String? value) => LoginValidator.identifier(value);
  String? validatePassword(String? value) => LoginValidator.password(value);

  Future<void> onLoginPressed(BuildContext context) async {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final request = LoginRequestModel(
      identifier: identifierController.text.trim(),
      password: passwordController.text,
    );

    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));
    debugPrint('Login sebagai $roleLabel -> ${request.identifier}');

    _isLoading = false;
    notifyListeners();

    if (!context.mounted) return;
    final nextRoute = isPetani ? '/home-petani' : '/home-pembeli';
    Navigator.pushReplacementNamed(context, nextRoute);
  }

  void onGoogleLoginPressed(BuildContext context) {
    debugPrint('Login dengan Google sebagai $roleLabel');
  }

  void onFacebookLoginPressed(BuildContext context) {
    debugPrint('Login dengan Facebook sebagai $roleLabel');
  }

  void onForgotPasswordPressed(BuildContext context) {
    Navigator.pushNamed(context, '/forgot-password');
  }

  void onRegisterPressed(BuildContext context) {
    Navigator.pushNamed(context, '/register', arguments: role);
  }

  void onBackPressed(BuildContext context) {
    Navigator.pop(context); 
  }

  @override
  void dispose() {
    identifierController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}