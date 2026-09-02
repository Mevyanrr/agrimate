import 'package:agrimate/core/appcolor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BottomNavItemData {
  final IconData icon;
  final String label;

  const BottomNavItemData({required this.icon, required this.label});
}

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color accentColor;
  final List<BottomNavItemData> items;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.accentColor = AppColors.greenprimary,
    this.items = const [
      BottomNavItemData(icon: Icons.home_rounded, label: 'Beranda'),
      BottomNavItemData(icon: Icons.storefront_rounded, label: 'Pasar'),
      BottomNavItemData(icon: Icons.add, label: 'Rencana'), 
      BottomNavItemData(icon: Icons.receipt_long_rounded, label: 'Transaksi'),
      BottomNavItemData(icon: Icons.person_rounded, label: 'Profil'),
    ],
  });

  static const int _centerIndex = 2;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88.h,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Bar putih dasar
          Container(
            height: 68.h,
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: List.generate(items.length, (index) {
                if (index == _centerIndex) {
                  return const Expanded(child: SizedBox.shrink());
                }
                return Expanded(
                  child: _NavItem(
                    data: items[index],
                    isActive: index == currentIndex,
                    accentColor: accentColor,
                    onTap: () => onTap(index),
                  ),
                );
              }),
            ),
          ),

          // Tombol tengah — elevated bulat
          Positioned(
            top: 0,
            child: GestureDetector(
              onTap: () => onTap(_centerIndex),
              child: Column(
                children: [
                  Container(
                    width: 56.w,
                    height: 56.w,
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withOpacity(0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(items[_centerIndex].icon, color: Colors.white, size: 26.sp),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    items[_centerIndex].label,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: currentIndex == _centerIndex
                          ? accentColor
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final BottomNavItemData data;
  final bool isActive;
  final Color accentColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.data,
    required this.isActive,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? accentColor : AppColors.textMuted;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(data.icon, color: color, size: 22.sp),
          SizedBox(height: 4.h),
          Text(
            data.label,
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}