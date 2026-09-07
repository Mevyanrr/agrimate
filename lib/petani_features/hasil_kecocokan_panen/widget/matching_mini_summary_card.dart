import 'package:agrimate/core/appcolor.dart';
import 'package:agrimate/petani_features/hasil_kecocokan_panen/model/rencana_summary_model.dart';
import 'package:agrimate/role_selection/model/role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MatchingMiniSummaryCard extends StatelessWidget {
  final RencanaSummaryModel rencana;
  final UserRole role;
  const MatchingMiniSummaryCard({super.key, required this.rencana, required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 10.r, offset: Offset(0, 2.h))],
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: const BoxDecoration(color: AppColors.lightorange, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(rencana.komoditasEmoji, style: TextStyle(fontSize: 20.sp)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rencana.komoditasName,
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${rencana.kuantitasKg} kg · ${rencana.rangeIsoLabel}',
                  style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}