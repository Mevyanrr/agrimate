import 'package:agrimate/core/appcolor.dart';
import 'package:agrimate/petani_features/home/view/home_page.dart';
import 'package:agrimate/role_selection/model/role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<void> showRatingSuccessSheet(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => const _RatingSuccessContent(),
  );
}

class _RatingSuccessContent extends StatefulWidget {
  const _RatingSuccessContent();

  @override
  State<_RatingSuccessContent> createState() => _RatingSuccessContentState();
}

class _RatingSuccessContentState extends State<_RatingSuccessContent> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) =>
                const HomeView(role: UserRole.petani), 
          ),
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.amberAccent.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Container(
                margin: EdgeInsets.all(10.w),
                decoration: const BoxDecoration(
                  color: AppColors.amberAccent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Penilaian berhasil dibuat!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Terima kasih telah memberikan penilaian!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
