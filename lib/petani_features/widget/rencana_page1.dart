import 'package:agrimate/core/appcolor.dart';
import 'package:agrimate/petani_features/rencana_panen/model/rencana_panen.dart';
import 'package:agrimate/petani_features/rencana_panen/viewmodel/rencana_panen_vm.dart';
import 'package:agrimate/role_selection/model/role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class Page1KomoditasView extends StatelessWidget {
  final UserRole role;

  const Page1KomoditasView({
    super.key,
    this.role = UserRole.petani,
  });

  static const KomoditasModel itemLainnya = KomoditasModel(
    id: 'lainnya',
    name: 'Lainnya',
    emoji: '📝',
  );

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RencanaViewModel>();

    final isPembeli = role == UserRole.pembeli;
    final title = isPembeli ? 'Butuh komoditas apa?' : 'Mau panen apa?';
    final accentColor = isPembeli ? AppColors.orangeprimary : AppColors.greenprimary;
    final accentColorLight = isPembeli ? AppColors.lightorange : AppColors.lightgreen;

    final displayList = [...vm.komoditasList, itemLainnya];
    final isLainnyaSelected = vm.selectedKomoditas?.id == 'lainnya';

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
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
            itemCount: displayList.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 2.5,
            ),
            itemBuilder: (context, index) {
              final item = displayList[index];
              final selected = vm.selectedKomoditas?.id == item.id;

              return _KomoditasCard(
                komoditas: item,
                selected: selected,
                accentColor: accentColor,
                accentColorLight: accentColorLight,
                onTap: () => vm.selectKomoditas(item),
              );
            },
          ),

          if (isLainnyaSelected) ...[
            SizedBox(height: 20.h),
            Text(
              'Nama Komoditas Lainnya',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            TextFormField(
              controller: vm.customKomoditasController, 
              onChanged: (val) => vm.setCustomKomoditasName(val),
              decoration: InputDecoration(
                hintText: 'Contoh: Jahe Merah',
                hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColors.borderDefault),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColors.borderDefault),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: accentColor, width: 1.5),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _KomoditasCard extends StatelessWidget {
  final KomoditasModel komoditas;
  final bool selected;
  final Color accentColor;
  final Color accentColorLight;
  final VoidCallback onTap;

  const _KomoditasCard({
    required this.komoditas,
    required this.selected,
    required this.accentColor,
    required this.accentColorLight,
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
          color: selected ? accentColorLight : AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: selected ? accentColor : AppColors.borderDefault,
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
                  color: selected ? accentColor : AppColors.textPrimary,
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