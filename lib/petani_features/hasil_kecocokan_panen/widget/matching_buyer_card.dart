import 'package:agrimate/core/appcolor.dart';
import 'package:agrimate/petani_features/hasil_kecocokan_panen/model/matching_buyer_model.dart';
import 'package:agrimate/role_selection/model/role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

String _formatRupiah(int value) {
  final str = value.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    final posFromEnd = str.length - i;
    buffer.write(str[i]);
    if (posFromEnd > 1 && posFromEnd % 3 == 1) buffer.write('.');
  }
  return buffer.toString();
}

String _formatEstimasi(int value) {
  if (value >= 1000) return 'Rp ${(value / 1000).toStringAsFixed(0)}rb';
  return 'Rp $value';
}

class MatchingBuyerCard extends StatelessWidget {
  final UserRole role;
  final MatchingBuyerModel buyer;
  final bool isLoading;
  final ValueChanged<bool> onRespond; 

  const MatchingBuyerCard({
    super.key,
    required this.buyer,
    required this.onRespond,
    required this.role,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final responded = buyer.status != BuyerResponseStatus.pending;

    final isPetani = role == UserRole.petani;
    final primaryColor = isPetani ? AppColors.greenprimary : AppColors.orangeprimary;
    final lightBgColor = isPetani ? AppColors.lightgreen : AppColors.lightorange;
    final darkTextColor = isPetani ? AppColors.darkgreen : AppColors.darkorange;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      buyer.name,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${buyer.type} · ${buyer.location}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.purpleAccentLight,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  '${buyer.matchPercentage}% cocok',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.purpleAccent,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _statBox(
                  'Alokasi',
                  '${buyer.alokasiKg} kg',
                  bgColor: lightBgColor,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _statBox(
                  'Harga',
                  'Rp ${_formatRupiah(buyer.hargaPerKg)}/kg',
                  bgColor: lightBgColor,
                  valueColor: primaryColor,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _statBox(
                  'Estimasi',
                  _formatEstimasi(buyer.estimasiRp),
                  bgColor: lightBgColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (responded)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10.h),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: buyer.status == BuyerResponseStatus.accepted
                    ? lightBgColor 
                    : AppColors.scaffoldGrey,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                buyer.status == BuyerResponseStatus.accepted ? 'Disetujui' : 'Ditolak',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: buyer.status == BuyerResponseStatus.accepted
                      ? darkTextColor 
                      : AppColors.textSecondary,
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isLoading ? null : () => onRespond(false),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.borderDefault),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: Text(
                      'Tolak',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : () => onRespond(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: isLoading
                        ? SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Setuju',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
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

  Widget _statBox(
    String label,
    String value, {
    Color? valueColor,
    required Color bgColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: bgColor, 
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}