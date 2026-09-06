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

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: isApplied ? AppColors.greenprimary : const Color(0xFFE2E8F0),
          width: isApplied ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: const BoxDecoration(
                  color: Color(0xFF23C45E),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8.w),

              Container(
                width: 48.w,
                height: 48.w,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F8EE), 
                  shape: BoxShape.circle,
                ),
                child: Text(
                  request.commodityEmoji,
                  style: TextStyle(fontSize: 22.sp),
                ),
              ),
              SizedBox(width: 12.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.commodityName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${request.buyerName} · ${request.location}',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),

              _BuyerTypeBadge(type: request.buyerType),
            ],
          ),

          SizedBox(height: 16.h),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          SizedBox(height: 16.h),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${request.quantityKg.toStringAsFixed(0)} kg · ${request.periodLabel}',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Rp ${_formatRupiah(request.pricePerKg)}/kg',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF23C45E),
                      ),
                    ),
                  ],
                ),
              ),

              OutlinedButton(
                onPressed: onDetailTap,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Detail',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF334155),
                  ),
                ),
              ),
              SizedBox(width: 8.w),

              ElevatedButton(
                onPressed: isApplied ? null : onApplyTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isApplied ? const Color(0xFFDCFCE7) : const Color(0xFF23C45E),
                  disabledBackgroundColor: const Color(0xFFDCFCE7),
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  isApplied ? 'Diajukan' : 'Ajukan →',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: isApplied ? const Color(0xFF23C45E) : Colors.white,
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

class _BuyerTypeBadge extends StatelessWidget {
  final BuyerType type;
  const _BuyerTypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    late Color bg;
    late Color fg;

    switch (type) {
      case BuyerType.restoran:
        bg = const Color(0xFFFFF1E5);
        fg = const Color(0xFFEA580C);
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
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        type.label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}