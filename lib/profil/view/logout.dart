import 'package:agrimate/core/appcolor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<bool?> showLogoutConfirmSheet(
  BuildContext context, {
  required Color accentColor,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => _LogoutSheetContent(accentColor: accentColor),
  );
}

class _LogoutSheetContent extends StatelessWidget {
  final Color accentColor;
  const _LogoutSheetContent({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 32.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          SizedBox(height: 20.h),

          Text(
            'Keluar dari Akun?',
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Kamu harus masuk kembali untuk mengakses AgriMate.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary, height: 1.4),
          ),
          SizedBox(height: 24.h),

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48.h,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.borderDefault),
                      backgroundColor: AppColors.scaffoldGrey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: Text(
                      'Batal',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: SizedBox(
                  height: 48.h,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      backgroundColor: const Color(0xFFFDECEC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: Text(
                      'Ya, Keluar',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}