import 'package:agrimate/core/appcolor.dart';
import 'package:agrimate/petani_features/home/model/home.dart';
import 'package:agrimate/role_selection/model/role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HarvestPlanCard extends StatelessWidget {
  final HarvestPlanModel plan;
  final VoidCallback onTap;
  final UserRole role;

  const HarvestPlanCard({super.key, required this.plan, required this.onTap, required this.role});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  plan.dateRangeLabel,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (plan.hasMatch)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.purpleAccentLight,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      'Ada Kecocokan',
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.purpleAccent,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.scaffoldGrey,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    plan.commodityEmoji,
                    style: TextStyle(fontSize: 22.sp),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.commodityName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${plan.totalWeightKg.toStringAsFixed(0)}kg',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: role == UserRole.pembeli
                              ? AppColors.orangeprimary
                              : AppColors.greenprimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Teralokasi',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${plan.allocatedWeightKg.toStringAsFixed(0)}/${plan.totalWeightKg.toStringAsFixed(0)}kg',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: LinearProgressIndicator(
                value: plan.progress,
                minHeight: 6.h,
                backgroundColor: AppColors.indicatorInactive,
                valueColor: const AlwaysStoppedAnimation(
                  AppColors.purpleAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
