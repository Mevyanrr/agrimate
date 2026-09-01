import 'package:agrimate/auth/model/otp.dart';
import 'package:agrimate/core/appcolor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<OtpMethod?> showOtpMethodSheet(
  BuildContext context, {
  required String phoneNumber,
  required Color accentColor,
  required Color accentColorLight,
}) {
  return showModalBottomSheet<OtpMethod>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _OtpMethodSheetContent(
      phoneNumber: phoneNumber,
      accentColor: accentColor,
      accentColorLight: accentColorLight,
    ),
  );
}

class _OtpMethodSheetContent extends StatelessWidget {
  final String phoneNumber;
  final Color accentColor;
  final Color accentColorLight;

  const _OtpMethodSheetContent({
    required this.phoneNumber,
    required this.accentColor,
    required this.accentColorLight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.r),
                topRight: Radius.circular(24.r),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset('assets/images/verif.png'),
                    SizedBox(width: 6.w),
                    Text(
                      'Verifikasi Nomor',
                      style: TextStyle(color: Colors.white, fontSize: 12.sp),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  'Kirim Kode OTP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kami akan mengirimkan kode OTP 4 digit ke nomor berikut:',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 12.h),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.phone,
                            color: Colors.white,
                            size: 14,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'Nomor Tujuan',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        phoneNumber,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),

                Text(
                  'Pilih metode pengiriman',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 12.h),

                ...otpMethodOptions.map((option) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: _MethodTile(
                      option: option,
                      accentColor: accentColor,
                      accentColorLight: accentColorLight,
                      onTap: () => Navigator.pop(context, option.method),
                    ),
                  );
                }),

                Text(
                  'Pastikan nomor yang Anda masukkan aktif dan dapat menerima OTP.',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  final OtpMethodOption option;
  final Color accentColor;
  final Color accentColorLight;
  final VoidCallback onTap;

  const _MethodTile({
    required this.option,
    required this.accentColor,
    required this.accentColorLight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderDefault),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: accentColorLight,
                borderRadius: BorderRadius.circular(10.r),
              ),
              padding: EdgeInsets.all(8.w),
              child: Image.asset(
                option.iconPath,
                fit: BoxFit.contain,
                color: accentColor,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    option.description,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
