import 'package:agrimate/core/appcolor.dart';
import 'package:agrimate/petani_features/pasar/model/pasar.dart';
import 'package:agrimate/petani_features/pasar/widget/buyer_reqcard.dart'
    show BuyerTypeBadge;
import 'package:agrimate/petani_features/pasar/widget/pasar_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<void> showProductDetailSheet(
  BuildContext context, {
  required BuyerRequestModel request,
  required PasarCardRole role,
  VoidCallback? onApply,
  VoidCallback? onCall,
  VoidCallback? onWhatsapp,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ProductDetailSheet(
      request: request,
      role: role,
      onApply: onApply,
      onCall: onCall,
      onWhatsapp: onWhatsapp,
    ),
  );
}

class ProductDetailSheet extends StatelessWidget {
  final BuyerRequestModel request;
  final PasarCardRole role;
  final VoidCallback? onApply;
  final VoidCallback? onCall;
  final VoidCallback? onWhatsapp;

  const ProductDetailSheet({
    super.key,
    required this.request,
    required this.role,
    this.onApply,
    this.onCall,
    this.onWhatsapp,
  });

  bool get _isPetani => role == PasarCardRole.petani;

  String _priceLabel() {
    final min = formatRupiah(request.pricePerKg);
    final max = request.maxPricePerKg;
    if (max != null && max > request.pricePerKg) {
      return 'Rp $min-${formatRupiah(max)}/kg';
    }
    return 'Rp $min/kg';
  }

  @override
  Widget build(BuildContext context) {
    final theme = PasarCardTheme.of(role);

    return SafeArea(
      child: Container(
        margin: EdgeInsets.only(top: 60.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 18.h),
                  decoration: BoxDecoration(
                    color: AppColors.borderDefault,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 48.w,
                    height: 48.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      request.commodityEmoji,
                      style: TextStyle(fontSize: 22.sp),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      request.commodityName,
                      style: TextStyle(
                        fontSize: 19.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  _isPetani
                      ? BuyerTypeBadge(type: request.buyerType)
                      : _VerifiedBadge(theme: theme),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: 60.w, top: 4.h),
                child: Text(
                  request.buyerName,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              if (_isPetani) ..._petaniRows() else ..._pembeliRows(theme),
              SizedBox(height: 20.h),
              Text(
                'Deskripsi',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                request.description,
                style: TextStyle(
                  fontSize: 13.sp,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 24.h),
              _isPetani
                  ? _buildSingleAction(context, theme)
                  : _buildDualAction(context, theme),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _petaniRows() {
    return [
      _DetailRow(label: 'Lokasi', value: request.location, icon: '📍'),
      _DetailRow(label: 'Periode', value: request.periodLabel, icon: '📅'),
      _DetailRow(
        label: 'Kebutuhan',
        value: '${request.quantityKg.toStringAsFixed(0)} kg',
      ),
      if (request.frequencyLabel != null)
        _DetailRow(
          label: 'Frekuensi',
          value: request.frequencyLabel!,
          icon: '🔁',
        ),
      _DetailRow(
        label: 'Budget',
        value: _priceLabel(),
        valueColor: AppColors.greenprimary,
        bold: true,
      ),
    ];
  }

  List<Widget> _pembeliRows(PasarCardTheme theme) {
    return [
      _DetailRow(label: 'Lokasi', value: request.location, icon: '📍'),
      _DetailRow(
        label: 'Periode Panen',
        value: request.periodLabel,
        icon: '📅',
      ),
      _DetailRow(
        label: 'Stok Tersedia',
        value: '${request.quantityKg.toStringAsFixed(0)} kg',
      ),
      if (request.minOrderKg != null)
        _DetailRow(
          label: 'Min. Order',
          value: '${request.minOrderKg!.toStringAsFixed(0)} kg',
        ),
      _DetailRow(
        label: 'Harga',
        value: _priceLabel(),
        valueColor: theme.primary,
        bold: true,
      ),
    ];
  }

  Widget _buildSingleAction(BuildContext context, PasarCardTheme theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).maybePop();
          onApply?.call();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryDark,
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(
          'Ajukan Penawaran →',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildDualAction(BuildContext context, PasarCardTheme theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).maybePop();
              onCall?.call();
            },
            icon: Icon(Icons.call, size: 16.sp, color: theme.primaryDark),
            label: Text(
              'Telepon',
              style: TextStyle(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w600,
                color: theme.primaryDark,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: theme.borderIdle),
              padding: EdgeInsets.symmetric(vertical: 13.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).maybePop();
              onWhatsapp?.call();
            },
            icon: Icon(Icons.chat, size: 16.sp, color: Colors.white),
            label: Text(
              'WhatsApp',
              style: TextStyle(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryDark,
              elevation: 0,
              padding: EdgeInsets.symmetric(vertical: 13.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final String? icon;
  final Color? valueColor;
  final bool bold;

  const _DetailRow({
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderDefault, width: 0.6),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
          ),
          Row(
            children: [
              if (icon != null) ...[
                Text(icon!, style: TextStyle(fontSize: 12.sp)),
                SizedBox(width: 4.w),
              ],
              Text(
                value,
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: bold ? FontWeight.bold : FontWeight.w600,
                  color: valueColor ?? AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// "Trusted seller" badge, colored to match the current role theme
/// (orangeprimary for the pembeli view).
class _VerifiedBadge extends StatelessWidget {
  final PasarCardTheme theme;
  const _VerifiedBadge({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: theme.primaryLight,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 12.sp, color: theme.primaryDark),
          SizedBox(width: 3.w),
          Text(
            'Terverifikasi',
            style: TextStyle(
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w600,
              color: theme.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}