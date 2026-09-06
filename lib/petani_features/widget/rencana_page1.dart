import 'package:agrimate/core/appcolor.dart';
import 'package:agrimate/petani_features/rencana_panen/model/rencana_panen.dart';
import 'package:agrimate/petani_features/rencana_panen/viewmodel/rencana_panen_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class Page1KomoditasView extends StatelessWidget {
  const Page1KomoditasView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RencanaViewModel>();

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mau Panen Apa?',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          SizedBox(height: 4.h),
          Text(
            'Pilih jenis komoditas',
            style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
          ),
          SizedBox(height: 18.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: vm.komoditasList.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 2.5,
            ),
            itemBuilder: (context, index) {
              final item = vm.komoditasList[index];
              final selected = vm.selectedKomoditas == item;
              return _KomoditasCard(
                komoditas: item,
                selected: selected,
                onTap: () => vm.selectKomoditas(item),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _KomoditasCard extends StatelessWidget {
  final KomoditasModel komoditas;
  final bool selected;
  final VoidCallback onTap;

  const _KomoditasCard({
    required this.komoditas,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: selected ? AppColors.lightgreen : AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: selected ? AppColors.greenprimary : AppColors.borderDefault,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(komoditas.emoji, style: TextStyle(fontSize: 22.sp)),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                komoditas.name,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}