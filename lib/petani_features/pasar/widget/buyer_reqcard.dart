import 'package:agrimate/core/appcolor.dart';
import 'package:agrimate/petani_features/pasar/model/pasar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BuyerRequestCard extends StatelessWidget {
  final BuyerRequestModel request;
  final VoidCallback onDetailTap;
  final VoidCallback onApplyTap;

  const BuyerRequestCard({
    super.key,
    required this.request,
    required this.onDetailTap,
    required this.onApplyTap,
  });

  String _formatRupiah(double value) {
    final digits = value.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      final posFromEnd = digits.length - i;
      buffer.write(digits[i]);
      if (posFromEnd > 1 && posFromEnd % 3 == 1) buffer.write('.');
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final isApplied = request.isApplied;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isApplied ? AppColors.greenprimary : AppColors.borderDefault,
              width: isApplied ? 1.4 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.scaffoldGrey,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      request.commodityEmoji,
                      style: TextStyle(fontSize: 18.sp),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      request.commodityName,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  BuyerTypeBadge(type: request.buyerType),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: 50.w, top: 2.h),
                child: Text(
                  '${request.buyerName} · ${request.location}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                '${request.quantityKg.toStringAsFixed(0)} kg · ${request.periodLabel}',
                style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
              ),
              SizedBox(height: 6.h),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Rp ${_formatRupiah(request.pricePerKg)}/kg',
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.greenprimary,
                      ),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: onDetailTap,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.borderDefault),
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: Text(
                      'Detail',
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  ElevatedButton(
                    onPressed: isApplied ? null : onApplyTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isApplied ? AppColors.lightgreen : AppColors.darkgreen,
                      disabledBackgroundColor: AppColors.lightgreen,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: Text(
                      isApplied ? 'Diajukan' : 'Ajukan →',
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w600,
                        color: isApplied ? AppColors.greenprimary : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: -3.h,
          left: 14.w,
          child: Container(
            width: 9.w,
            height: 9.w,
            decoration: BoxDecoration(
              color: AppColors.greenprimary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class BuyerTypeBadge extends StatelessWidget {
  final BuyerType type;
  const BuyerTypeBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    late Color bg;
    late Color fg;

    switch (type) {
      case BuyerType.restoran:
        bg = const Color(0xFFFFF1E0);
        fg = const Color(0xFFB8722B);
        break;
      case BuyerType.distributor:
        bg = AppColors.purpleAccentLight;
        fg = AppColors.purpleAccent;
        break;
      case BuyerType.catering:
        bg = AppColors.lightgreen;
        fg = AppColors.greenprimary;
        break;
      case BuyerType.koperasi:
        bg = const Color(0xFFE3F0FF);
        fg = const Color(0xFF2E6DB4);
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20.r)),
      child: Text(
        type.label,
        style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}