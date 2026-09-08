import 'package:agrimate/core/appcolor.dart';
import 'package:agrimate/role_selection/model/role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class KembaliPillButton extends StatelessWidget {
  final VoidCallback onTap;
  final UserRole role;

  const KembaliPillButton({
    super.key,
    required this.onTap,
    this.role = UserRole.petani,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = role == UserRole.pembeli
        ? AppColors.orangeprimary
        : AppColors.greenprimary;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(30.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(30.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 8.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_back, color: activeColor, size: 18.sp),
              SizedBox(width: 6.w),
              Text(
                'Kembali',
                style: TextStyle(
                  color: activeColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}