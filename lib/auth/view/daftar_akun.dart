import 'package:agrimate/auth/viewmodel/daftar_akun_vm.dart';
import 'package:agrimate/core/appcolor.dart';
import 'package:agrimate/role_selection/model/role.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class RegisterView extends StatelessWidget {
  final UserRole role;

  const RegisterView({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterViewModel(role: role),
      child: const _RegisterBody(),
    );
  }
}

class _RegisterBody extends StatelessWidget {
  const _RegisterBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RegisterViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Form(
            key: vm.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),

                GestureDetector(
                  onTap: () => vm.onBackPressed(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.r),
                      border: Border.all(color: AppColors.borderDefault),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back, size: 16.sp, color: AppColors.textPrimary),
                        SizedBox(width: 6.w),
                        Text(
                          'Kembali ke Masuk',
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
                  child: Image.asset('assets/images/logo_withname.png', width: 130.w),
                ),
                SizedBox(height: 28.h),

                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    children: [
                      const TextSpan(text: 'Daftar sebagai '),
                      TextSpan(text: vm.roleLabel, style: TextStyle(color: vm.accentColor)),
                    ],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Lengkapi data dirimu di bawah ini untuk bergabung dengan AgriMate',
                  style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
                ),
                SizedBox(height: 24.h),

                _FieldLabel('Alamat Email (Opsional)'),
                SizedBox(height: 6.h),
                TextFormField(
                  controller: vm.emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: vm.validateEmail,
                  decoration: _inputDecoration(hint: 'Enter Input'),
                ),
                SizedBox(height: 16.h),

                _FieldLabel('Nomor WhatsApp Aktif'),
                SizedBox(height: 6.h),
                TextFormField(
                  controller: vm.phoneController,
                  keyboardType: TextInputType.phone,
                  validator: vm.validatePhone,
                  decoration: _inputDecoration(hint: 'Enter Input'),
                ),
                SizedBox(height: 16.h),

                _FieldLabel('Password'),
                SizedBox(height: 6.h),
                TextFormField(
                  controller: vm.passwordController,
                  obscureText: vm.obscurePassword,
                  validator: vm.validatePassword,
                  decoration: _inputDecoration(hint: 'Enter Input').copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        vm.obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20.sp,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: vm.togglePasswordVisibility,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                _FieldLabel('Ulangi Password'),
                SizedBox(height: 6.h),
                TextFormField(
                  controller: vm.confirmPasswordController,
                  obscureText: vm.obscureConfirmPassword,
                  validator: vm.validateConfirmPassword,
                  decoration: _inputDecoration(hint: 'Enter Input').copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        vm.obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20.sp,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: vm.toggleConfirmPasswordVisibility,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: vm.isLoading ? null : () => vm.onSubmitPressed(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: vm.accentColor,
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
                                color: Colors.white, strokeWidth: 2.5),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Kirim Kode OTP',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                            ],
                          ),
                  ),
                ),
                SizedBox(height: 20.h),

                Center(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
                      children: [
                        const TextSpan(text: 'Sudah punya akun? '),
                        TextSpan(
                          text: 'Masuk di sini',
                          style: TextStyle(color: vm.accentColor, fontWeight: FontWeight.w600),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => vm.onLoginHerePressed(context),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                Center(
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(fontSize: 11.5.sp, color: AppColors.textSecondary),
                      children: [
                        const TextSpan(text: 'Dengan mendaftar, kamu menyetujui '),
                        TextSpan(
                          text: 'Syarat & Ketentuan',
                          style: TextStyle(
                            color: vm.accentColor,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const TextSpan(text: ' serta '),
                        TextSpan(
                          text: 'Kebijakan Privasi',
                          style: TextStyle(
                            color: vm.accentColor,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const TextSpan(text: '.'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppColors.borderDefault),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppColors.borderDefault),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppColors.textPrimary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}