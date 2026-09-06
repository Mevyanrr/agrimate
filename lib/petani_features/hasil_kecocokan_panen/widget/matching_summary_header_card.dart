import 'package:agrimate/core/appcolor.dart';
import 'package:agrimate/petani_features/hasil_kecocokan_panen/model/matching_result_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MatchingSummaryHeaderCard extends StatelessWidget {
  final MatchingResultModel result;
  const MatchingSummaryHeaderCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: const BoxDecoration(color: AppColors.lightorange, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(result.komoditasEmoji, style: TextStyle(fontSize: 20.sp)),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(result.komoditasName,
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  SizedBox(height: 2.h),
                  Text('Total: ${result.totalKg} kg',
                      style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Berpotensi Terjual', style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
              Text(
                '${result.terjualKg} dari ${result.totalKg} kg',
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.purpleAccent),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: SizedBox(
              height: 8.h,
              child: Stack(
                children: [
                  Container(color: AppColors.scaffoldGrey),
                  FractionallySizedBox(
                    widthFactor: result.allocatedPercentage,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [AppColors.greenprimary, AppColors.purpleAccent]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(result.allocatedPercentage * 100).round()}% teralokasi',
              style: TextStyle(fontSize: 11.sp, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}