import 'package:agrimate/core/appcolor.dart';
import 'package:agrimate/petani_features/rencana_panen/viewmodel/rencana_panen_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class Page2KuantitasView extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color accentColor;
  final Color accentColorLight;

  const Page2KuantitasView({
    super.key,
    this.title = 'Kira-kira berapa kg?',
    this.subtitle = 'Estimasi total yang dapat dipanen',
    this.accentColor = AppColors.greenprimary,
    this.accentColorLight = AppColors.lightgreen,
  });

  static const List<double> quickPicks = [50, 100, 500, 1000];

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RencanaViewModel>();

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
          SizedBox(height: 36.h),
          Center(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: vm.kuantitas.toInt().toString(),
                    style: TextStyle(
                      fontSize: 40.sp,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                  TextSpan(
                    text: ' kg',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: accentColor,
              inactiveTrackColor: accentColorLight,
              thumbColor: accentColor,
              overlayColor: accentColor.withOpacity(0.15),
              trackHeight: 4.h,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 9.r),
            ),
            child: Slider(
              min: 0,
              max: RencanaViewModel.maxKuantitas,
              value: vm.kuantitas,
              onChanged: (value) => vm.setKuantitas(value),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: quickPicks.map((value) {
              final isSelected = vm.kuantitas == value;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: OutlinedButton(
                    onPressed: () => vm.setKuantitas(value),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isSelected ? accentColorLight : AppColors.surface,
                      side: BorderSide(
                        color: isSelected ? accentColor : AppColors.borderDefault,
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    ),
                    child: Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? accentColor : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 10.h),
          Center(
            child: Text(
              '(maks. 10.000kg)',
              style: TextStyle(fontSize: 12.sp, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}