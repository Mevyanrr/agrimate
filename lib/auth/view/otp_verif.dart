import 'package:agrimate/auth/model/otp.dart';
import 'package:agrimate/core/appcolor.dart';
import 'package:agrimate/role_selection/model/role.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../viewmodel/otp_vm.dart';

class OtpVerificationView extends StatelessWidget {
  final UserRole role;
  final String phoneNumber;
  final OtpMethod method;

  const OtpVerificationView({
    super.key,
    required this.role,
    required this.phoneNumber,
    required this.method,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          OtpViewModel(role: role, phoneNumber: phoneNumber, method: method),
      child: const _OtpBody(),
    );
  }
}

class _OtpBody extends StatelessWidget {
  const _OtpBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OtpViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),

              GestureDetector(
                onTap: () => vm.onBackPressed(context),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.r),
                    border: Border.all(color: AppColors.borderDefault),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_back,
                        size: 16.sp,
                        color: AppColors.textPrimary,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Kembali ke Daftar',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              Center(
                child: Image.asset(
                  'assets/images/logo_withname.png',
                  width: 130.w,
                ),
              ),
              SizedBox(height: 32.h),

              Text(
                'Verifikasi OTP',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  children: [
                    const TextSpan(text: 'Masukkan '),
                    const TextSpan(
                      text: '6 digit kode',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextSpan(
                      text:
                          ' yang telah kami kirimkan ke nomor ${vm.phoneNumber}',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 28.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(OtpViewModel.otpLength, (index) {
                  return _OtpBox(
                    controller: vm.controllers[index],
                    focusNode: vm.focusNodes[index],
                    accentColorLight: vm.accentColorLight,
                    accentColor: vm.accentColor,
                    onChanged: (value) => vm.onDigitChanged(index, value),
                  );
                }),
              ),
              SizedBox(height: 28.h),

              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: (!vm.isComplete || vm.isLoading)
                      ? null
                      : () => vm.onVerifyPressed(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: vm.accentColor,
                    disabledBackgroundColor: vm.accentColor.withValues(
                      alpha: 0.4,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: vm.isLoading
                      ? SizedBox(
                          width: 22.w,
                          height: 22.w,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          'Verifikasi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 20.h),

              Center(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                    ),
                    children: [
                      const TextSpan(text: 'Belum menerima kode? '),
                      TextSpan(
                        text: 'Kirim Ulang',
                        style: TextStyle(
                          color: vm.accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => vm.onResendPressed(context),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Center(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                    ),
                    children: [
                      const TextSpan(text: 'Atau '),
                      TextSpan(
                        text: 'Gunakan Cara Lain',
                        style: TextStyle(
                          color: vm.accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => vm.onUseAnotherMethodPressed(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Color accentColorLight;
  final Color accentColor;
  final ValueChanged<String> onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.accentColorLight,
    required this.accentColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48.w,
      height: 58.w,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: accentColorLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide(color: accentColor, width: 1.5),
          ),
        ),
      ),
    );
  }
}
