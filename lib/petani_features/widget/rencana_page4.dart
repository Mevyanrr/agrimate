import 'package:agrimate/core/appcolor.dart';
import 'package:agrimate/petani_features/rencana_panen/viewmodel/rencana_panen_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class Page4KonfirmasiView extends StatelessWidget {
  final String title;
  final String subtitle;
  final String confirmationMessage;
  final Color accentColor;
  final Color accentColorLight;
  final Color accentColorDark;
  final Color iconBgColor;
  final String fallbackEmoji;

  const Page4KonfirmasiView({
    super.key,
    this.title = 'Cek dulu, ya!',
    this.subtitle = 'Pastikan semua sudah benar',
    this.confirmationMessage =
        'Setelah diajukan, sistem kami akan mulai mencarikan pembeli yang paling cocok.',
    this.accentColor = AppColors.greenprimary,
    this.accentColorLight = AppColors.lightgreen,
    this.accentColorDark = AppColors.darkgreen,
    this.iconBgColor = AppColors.lightorange,
    this.fallbackEmoji = '🌱',
  });

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    final mm = date.month.toString().padLeft(2, '0');
    return '${date.year}-$mm-${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RencanaViewModel>();
    final komoditas = vm.selectedKomoditas;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
          ),
          SizedBox(height: 18.h),
          Container(
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
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    komoditas?.emoji ?? fallbackEmoji,
                    style: TextStyle(fontSize: 24.sp),
                  ),
                ),
                SizedBox(height: 16.h),
                _SummaryRow(label: 'Komoditas', value: komoditas?.name ?? '-'),
                SizedBox(height: 12.h),
                _SummaryRow(
                  label: 'Kuantitas',
                  value: '${vm.kuantitas.toInt()} kg',
                  valueColor: accentColor,
                ),
                SizedBox(height: 12.h),
                _SummaryRow(label: 'Mulai', value: _formatDate(vm.tanggalMulai)),
                SizedBox(height: 12.h),
                _SummaryRow(label: 'Selesai', value: _formatDate(vm.tanggalSelesai)),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: accentColorLight,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              confirmationMessage,
              style: TextStyle(fontSize: 13.sp, color: accentColorDark, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary)),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}