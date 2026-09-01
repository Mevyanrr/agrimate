import 'package:agrimate/auth/model/otp.dart';
import 'package:agrimate/backend/backend_dependencies.dart';
import 'package:agrimate/backend/core/errors/backend_exception.dart';
import 'package:agrimate/backend/features/auth/domain/entities/auth_registration.dart';
import 'package:agrimate/core/appcolor.dart';
import 'package:agrimate/role_selection/model/role.dart';
import 'package:flutter/material.dart';

class OtpViewModel extends ChangeNotifier {
  final UserRole role;
  final String phoneNumber;
  final OtpMethod method;
  static const int otpLength = 6;
  late final _authRepository = BackendDependencies.create().authRepository;

  OtpViewModel({
    required this.role,
    required this.phoneNumber,
    required this.method,
  });

  final List<TextEditingController> controllers = List.generate(
    otpLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> focusNodes = List.generate(
    otpLength,
    (_) => FocusNode(),
  );

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool get isComplete => controllers.every((c) => c.text.trim().isNotEmpty);

  String get otpCode => controllers.map((c) => c.text).join();

  bool get isPetani => role == UserRole.petani;
  Color get accentColor =>
      isPetani ? AppColors.greenprimary : AppColors.orangeprimary;
  Color get accentColorLight =>
      isPetani ? AppColors.lightgreen : AppColors.lightorange;

  void onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < otpLength - 1) {
      focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
    notifyListeners();
  }

  Future<void> onVerifyPressed(BuildContext context) async {
    if (!isComplete) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _authRepository.verifyPhoneOtp(phone: phoneNumber, token: otpCode);
      if (!context.mounted) return;
      final nextRoute = isPetani ? '/home-petani' : '/home-pembeli';
      Navigator.pushNamedAndRemoveUntil(context, nextRoute, (route) => false);
    } on BackendException catch (error) {
      if (context.mounted) _showMessage(context, error.message);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> onResendPressed(BuildContext context) async {
    try {
      await _authRepository.resendPhoneOtp(
        phone: phoneNumber,
        channel: method == OtpMethod.whatsapp
            ? AuthOtpChannel.whatsapp
            : AuthOtpChannel.sms,
      );
      if (context.mounted) {
        _showMessage(context, 'Kode OTP baru sudah dikirim.');
      }
    } on BackendException catch (error) {
      if (context.mounted) _showMessage(context, error.message);
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void onUseAnotherMethodPressed(BuildContext context) {
    Navigator.pop(context);
  }

  void onBackPressed(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    for (final c in controllers) {
      c.dispose();
    }
    for (final f in focusNodes) {
      f.dispose();
    }
    super.dispose();
  }
}
