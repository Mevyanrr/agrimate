import 'package:agrimate/auth/viewmodel/masuk_vm.dart';
import 'package:agrimate/core/appcolor.dart';
import 'package:agrimate/role_selection/model/role.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class LoginView extends StatelessWidget {
  final UserRole role;

  const LoginView({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(role: role),
      child: const _LoginBody(),
    );
  }
}

class _LoginBody extends StatelessWidget {
  const _LoginBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginViewModel>();

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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back, size: 18.sp, color: AppColors.textPrimary),
                      SizedBox(width: 6.w),
                      Text(
                        'Kembali',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                Center(
                  child: Image.asset(
                    'assets/images/logo_withname.png',
                    width: 130.w,
                  ),
                ),
                SizedBox(height: 28.h),

                Text(
                  'Selamat Datang 👋',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),

                RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
                    children: [
                      const TextSpan(
                          text: 'Masuk ke akun AgriMate-mu dan mulai bertransaksi sebagai '),
                      TextSpan(
                        text: vm.roleLabel,
                        style: TextStyle(
                          color: vm.accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                Row(
                  children: [
                    Expanded(
                      child: _SocialButton(
                        iconPath: 'assets/images/google.png',
                        label: 'Google',
                        onTap: () => vm.onGoogleLoginPressed(context),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _SocialButton(
                        iconPath: 'assets/images/fb.png',
                        label: 'Facebook',
                        onTap: () => vm.onFacebookLoginPressed(context),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),

                Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.borderDefault)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Text(
                        'atau dengan WhatsApp / Email',
                        style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                      ),
                    ),
                    Expanded(child: Divider(color: AppColors.borderDefault)),
                  ],
                ),
                SizedBox(height: 20.h),

                _FieldLabel('Nomor WhatsApp / Email'),
                SizedBox(height: 6.h),
                TextFormField(
                  controller: vm.identifierController,
                  keyboardType: TextInputType.emailAddress,
                  validator: vm.validateIdentifier,
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
                SizedBox(height: 8.h),

                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => vm.onForgotPasswordPressed(context),
                    child: Text(
                      'Lupa password?',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: vm.accentColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: vm.isLoading ? null : () => vm.onLoginPressed(context),
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
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Masuk Sekarang',
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
                        const TextSpan(text: 'Belum punya akun? '),
                        TextSpan(
                          text: 'Daftar di sini',
                          style: TextStyle(
                            color: vm.accentColor,
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => vm.onRegisterPressed(context),
                        ),
                      ],
                    ),
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

class _SocialButton extends StatelessWidget {
  final String iconPath;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({
    required this.iconPath,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderDefault),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(iconPath, width: 20.w, height: 20.w),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}