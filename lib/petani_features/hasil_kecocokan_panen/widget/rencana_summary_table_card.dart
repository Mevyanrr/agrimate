import 'package:agrimate/core/appcolor.dart';
import 'package:agrimate/petani_features/hasil_kecocokan_panen/model/rencana_summary_model.dart';
import 'package:agrimate/role_selection/model/role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RencanaSummaryTableCard extends StatelessWidget {
  final RencanaSummaryModel rencana;
  final UserRole role;

  const RencanaSummaryTableCard({
    super.key, 
    required this.rencana,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            color: AppColors.scaffoldGrey,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Text(
              'Ringkasan Rencana',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                _row('Komoditas', rencana.komoditasName),
                SizedBox(height: 14.h),
               _row(
  'Jumlah', 
  '${rencana.kuantitasKg} kg', 
  valueColor: role == UserRole.pembeli 
      ? AppColors.orangeprimary 
      : AppColors.greenprimary,
),
                SizedBox(height: 14.h),
                _row('Periode', rencana.periodeLabel),
                SizedBox(height: 14.h),
                _row('Lokasi Kirim', rencana.lokasiKirim),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary)),
        Text(
          value,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: valueColor ?? AppColors.textPrimary),
        ),
      ],
    );
  }
}