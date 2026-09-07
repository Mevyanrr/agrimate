import 'package:agrimate/core/appcolor.dart';
import 'package:agrimate/role_selection/model/role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MatchingBottomActions extends StatelessWidget {
  final VoidCallback onLihatKebutuhan;
  final VoidCallback onKembaliBeranda;
  final UserRole role;

  const MatchingBottomActions({
    super.key,
    required this.onLihatKebutuhan,
    required this.onKembaliBeranda,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final isPetani = role == UserRole.petani;
    final primaryColor = isPetani ? AppColors.greenprimary : AppColors.orangeprimary;
    final buttonText = isPetani ? 'Lihat Rencana Saya' : 'Lihat Kebutuhan Saya';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 20.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 12.r,
            offset: Offset(0, -2.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: onLihatKebutuhan,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor, 
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                buttonText,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: OutlinedButton(
              onPressed: onKembaliBeranda,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Kembali ke Beranda',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}