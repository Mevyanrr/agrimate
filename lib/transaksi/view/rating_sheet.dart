import 'package:agrimate/core/appcolor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../viewmodel/rating_vm.dart';

/// Return `double` rating (1-5) kalau berhasil dikirim, `null` kalau dibatalkan.
Future<double?> showRatingSheet(
  BuildContext context, {
  required Color accentColor,
  required String transactionId,
}) {
  return showModalBottomSheet<double>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ChangeNotifierProvider(
      create: (_) => RatingViewModel(transactionId: transactionId),
      child: _RatingSheetContent(accentColor: accentColor),
    ),
  );
}

class _RatingSheetContent extends StatelessWidget {
  final Color accentColor;
  const _RatingSheetContent({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RatingViewModel>();

    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 32.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
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
                  AppColors.goldStar.withOpacity(0.25),
                  Colors.transparent,
                ],
              ),
            ),
            child: Icon(
              Icons.star_rounded,
              color: AppColors.goldStar,
              size: 44.sp,
            ),
          ),
          SizedBox(height: 12.h),

          Text(
            'Beri Penilaian',
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Bagaimana pengalaman transaksimu?',
            style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
          ),
          SizedBox(height: 20.h),
          Divider(color: AppColors.borderDefault),
          SizedBox(height: 16.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starValue = index + 1;
              final isFilled = starValue <= vm.selectedStars;
              return GestureDetector(
                onTap: () => vm.onStarTapped(starValue),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Icon(
                    Icons.star_rounded,
                    size: 40.sp,
                    color: isFilled
                        ? AppColors.goldStar
                        : AppColors.goldStarLight,
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 24.h),

          if (vm.errorMessage != null) ...[
            Text(
              vm.errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.redAccent, fontSize: 12.sp),
            ),
            SizedBox(height: 12.h),
          ],

          if (vm.canSubmit)
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: OutlinedButton(
                onPressed: vm.isSubmitting
                    ? null
                    : () async {
                        final success = await vm.onSubmitPressed();
                        if (success && context.mounted) {
                          Navigator.pop(context, vm.selectedStars.toDouble());
                        }
                      },
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.goldButtonBg,
                  side: BorderSide(color: AppColors.goldStar),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: vm.isSubmitting
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: CircularProgressIndicator(
                          color: AppColors.goldStar,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Kirim',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.goldStar,
                        ),
                      ),
              ),
            ),
          SizedBox(height: 14.h),

          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Text(
              'Kembali',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
