import 'package:agrimate/core/appcolor.dart';
import 'package:agrimate/petani_features/pasar/model/pasar.dart';
import 'package:agrimate/petani_features/pasar/widget/pasar_theme.dart';
import 'package:agrimate/petani_features/pasar/widget/product_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BuyerRequestCard extends StatelessWidget {
  final BuyerRequestModel request;
  final VoidCallback onDetailTap;
  final VoidCallback onApplyTap;

  final VoidCallback? onCallTap;
  final VoidCallback? onWhatsappTap;

  final PasarCardRole role;

  const BuyerRequestCard({
    super.key,
    required this.request,
    required this.onDetailTap,
    required this.onApplyTap,
    this.onCallTap,
    this.onWhatsappTap,
    this.role = PasarCardRole.petani,
  });

  String _priceLabel() {
    final min = formatRupiah(request.pricePerKg);
    final max = request.maxPricePerKg;
    if (max != null && max > request.pricePerKg) {
      return 'Rp $min-${formatRupiah(max)}/kg';
    }
    return 'Rp $min/kg';
  }

  String _actionLabel(bool isApplied) {
    if (role == PasarCardRole.pembeli) {
      return isApplied ? 'Dihubungi' : 'Hubungi';
    }
    return isApplied ? 'Diajukan' : 'Ajukan';
  }

  void _openDetail(BuildContext context) {
    onDetailTap();
    showProductDetailSheet(
      context,
      request: request,
      role: role,
      onApply: onApplyTap,
      onCall: onCallTap ?? onApplyTap,
      onWhatsapp: onWhatsappTap ?? onApplyTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isApplied = request.isApplied;
    final theme = PasarCardTheme.of(role);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isApplied ? theme.primary : theme.borderIdle,
          width: isApplied ? 1.4 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                margin: EdgeInsets.only(right: 8.w),
                decoration:
                    BoxDecoration(color: theme.primary, shape: BoxShape.circle),
              ),
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
            padding: EdgeInsets.only(left: 66.w, top: 2.h),
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
                  _priceLabel(),
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.primary,
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: () => _openDetail(context),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.borderDefault),
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
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
                      isApplied ? theme.primaryLight : theme.primaryDark,
                  disabledBackgroundColor: theme.primaryLight,
                  elevation: 0,
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: Text(
                  _actionLabel(isApplied),
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w600,
                    color: isApplied ? theme.primary : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20.r)),
      child: Text(
        type.label,
        style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}