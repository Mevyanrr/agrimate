import 'package:agrimate/core/appcolor.dart';
import 'package:agrimate/core/widget/appbar.dart';
import 'package:agrimate/core/widget/navbar_petani.dart';
import 'package:agrimate/profil/model/profil.dart';
import 'package:agrimate/profil/view/logout.dart';
import 'package:agrimate/profil/viewmodel/profil_vm.dart';
import 'package:agrimate/role_selection/model/role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ProfileView extends StatelessWidget {
  final UserRole role;
  const ProfileView({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel(role: role),
      child: const _ProfileBody(),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();
    final accentColor = vm.isPetani
        ? AppColors.greenprimary
        : AppColors.orangeprimary;
    final accentLight = vm.isPetani
        ? AppColors.lightgreen
        : AppColors.lightorange;

    return Scaffold(
      backgroundColor: AppColors.scaffoldGrey,
      bottomNavigationBar: AppBottomNav(
        currentIndex: vm.currentNavIndex,
        accentColor: AppColors.greenprimary,
        onTap: (index) => vm.onNavTap(context, index),
      ),
      body: SafeArea(
        bottom: false,
        child: vm.state == ProfileLoadState.loading
            ? Center(child: CircularProgressIndicator(color: accentColor))
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    HomeAppBar(
                      roleLabel: vm.isPetani ? 'Petani' : 'Pembeli',
                      accentColor: accentColor,
                      onNotificationTap: () =>
                          Navigator.pushNamed(context, '/notifikasi'),
                      onSettingsTap: () =>
                          Navigator.pushNamed(context, '/pengaturan'),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profil Saya',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 16.h),

                          _ProfileCard(
                            profile: vm.profile!,
                            accentColor: accentColor,
                            onEditPressed: () =>
                                vm.onEditProfilePressed(context),
                          ),

                          Padding(
                            padding: EdgeInsets.only(top: 12.h),
                            child: _MenuTile(
                              item: vm.menuItems.first,
                              accentLight: accentLight,
                              onTap: () => vm.onMenuItemPressed(
                                context,
                                vm.menuItems.first,
                              ),
                              isCardStyle: true,
                            ),
                          ),
                          SizedBox(height: 20.h),

                          ...vm.menuItems.skip(1).map((item) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: _MenuTile(
                                item: item,
                                accentLight: accentLight,
                                onTap: () =>
                                    vm.onMenuItemPressed(context, item),
                              ),
                            );
                          }),
                          SizedBox(height: 12.h),

                          // Tombol Keluar
                          SizedBox(
                            width: double.infinity,
                            height: 52.h,
                            child: OutlinedButton(
                              onPressed: vm.isLoggingOut
                                  ? null
                                  : () async {
                                      final confirmed =
                                          await showLogoutConfirmSheet(
                                            context,
                                            accentColor: accentColor,
                                          );
                                      if (confirmed == true &&
                                          context.mounted) {
                                        await vm.onConfirmLogout(context);
                                      }
                                    },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.red),
                                backgroundColor: const Color(0xFFFDECEC),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                              ),
                              child: vm.isLoggingOut
                                  ? SizedBox(
                                      width: 20.w,
                                      height: 20.w,
                                      child: const CircularProgressIndicator(
                                        color: Colors.red,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Keluar dari Akun',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.red,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final ProfileModel profile;
  final Color accentColor;
  final VoidCallback onEditPressed;

  const _ProfileCard({
    required this.profile,
    required this.accentColor,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: accentColor,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: EdgeInsets.all(2.5.w),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 26.r,
                  backgroundColor: AppColors.scaffoldGrey,
                  backgroundImage: profile.photoUrl != null
                      ? NetworkImage(profile.photoUrl!)
                      : null,
                  child: profile.photoUrl == null
                      ? Icon(Icons.person, color: accentColor, size: 26.sp)
                      : null,
                ),
              ),

              if (profile.rating != null)
                Positioned(
                  top: -8.h,
                  left: 8.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 7.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          profile.rating!.toStringAsFixed(0),
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Icon(
                          Icons.star_rounded,
                          size: 11.sp,
                          color: Colors.amber,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: 12.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  profile.location,
                  style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                ),
                SizedBox(height: 8.h),
                if (profile.isVerified)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child:
                        Text(
                          'Terverifikasi',
                          style: TextStyle(
                            color: AppColors.greenprimary,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                  ),
              ],
            ),
          ),

          GestureDetector(
            onTap: onEditPressed,
            child: Container(
              width: 58.w,
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_outlined, color: accentColor, size: 16.sp),
                  SizedBox(height: 2.h),
                  Text(
                    'Edit Profil',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
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

class _MenuTile extends StatelessWidget {
  final ProfileMenuItem item;
  final Color accentLight;
  final VoidCallback onTap;
  final bool isCardStyle;

  const _MenuTile({
    required this.item,
    required this.accentLight,
    required this.onTap,
    this.isCardStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(
            isCardStyle ? 0 : 14.r,
          ).copyWith(topLeft: isCardStyle ? const Radius.circular(0) : null),
          border: isCardStyle
              ? null
              : Border.all(color: AppColors.borderDefault),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              alignment: Alignment.center,
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: accentLight,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Image.asset(item.iconPath, fit: BoxFit.contain),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20.sp),
          ],
        ),
      ),
    );
  }
}
