import 'package:agrimate/auth/model/masuk.dart';
import 'package:agrimate/backend/backend_dependencies.dart';
import 'package:agrimate/backend/core/errors/backend_exception.dart';
import 'package:agrimate/backend/features/auth/domain/entities/auth_registration.dart';
import 'package:agrimate/core/appcolor.dart';
import 'package:agrimate/role_selection/model/role.dart';
import 'package:flutter/material.dart';

class LoginViewModel extends ChangeNotifier {
  final UserRole role;
  late final _authRepository = BackendDependencies.create().authRepository;

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

  bool _isSocialLoginPending = false;
  bool get isSocialLoginPending => _isSocialLoginPending;

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

    try {
      await _authRepository.login(
        identifier: request.identifier,
        password: request.password,
        expectedRole: isPetani ? AuthUserRole.farmer : AuthUserRole.buyer,
      );
      if (!context.mounted) return;
      final nextRoute = isPetani ? '/home-petani' : '/home-pembeli';
      Navigator.pushNamedAndRemoveUntil(context, nextRoute, (route) => false);
    } on BackendException catch (error) {
      if (context.mounted) _showError(context, error.message);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> onGoogleLoginPressed(BuildContext context) async {
    await _socialLogin(context, _authRepository.loginWithGoogle);
  }

  Future<void> onFacebookLoginPressed(BuildContext context) async {
    await _socialLogin(context, _authRepository.loginWithFacebook);
  }

  Future<void> _socialLogin(
    BuildContext context,
    Future<void> Function() login,
  ) async {
    _isSocialLoginPending = true;
    _isLoading = true;
    notifyListeners();
    try {
      await login();
    } on BackendException catch (error) {
      _isSocialLoginPending = false;
      if (context.mounted) _showError(context, error.message);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> onSocialLoginCompleted(BuildContext context) async {
    if (!_isSocialLoginPending) return;
    _isSocialLoginPending = false;
    _isLoading = true;
    notifyListeners();

    try {
      await _authRepository.completeSocialLogin(
        expectedRole: isPetani ? AuthUserRole.farmer : AuthUserRole.buyer,
      );
      if (!context.mounted) return;
      final nextRoute = isPetani ? '/home-petani' : '/home-pembeli';
      Navigator.pushNamedAndRemoveUntil(context, nextRoute, (route) => false);
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

  void onForgotPasswordPressed(BuildContext context) {
    _showError(context, 'Fitur lupa password belum tersedia.');
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
