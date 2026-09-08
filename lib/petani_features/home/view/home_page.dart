import 'package:agrimate/core/appcolor.dart';
import 'package:agrimate/core/widget/appbar.dart';
import 'package:agrimate/core/widget/navbar_petani.dart';
import 'package:agrimate/petani_features/home/model/home.dart';
import 'package:agrimate/petani_features/widget/card_rencanapanen.dart';
import 'package:agrimate/role_selection/model/role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../viewmodel/home_vm.dart';

class HomeView extends StatelessWidget {
  final UserRole role;

  const HomeView({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(role: role),
      child: const _HomeBody(),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldGrey,
      bottomNavigationBar: AppBottomNav(
        currentIndex: vm.currentNavIndex,
        accentColor: vm.primaryColor,
        onTap: (index) => vm.onNavTap(context, index),
      ),
      body: SafeArea(
        bottom: false,
        child: Builder(
          builder: (context) {
            if (vm.state == HomeLoadState.loading) {
              return Center(
                child: CircularProgressIndicator(color: vm.primaryColor),
              );
            }
            if (vm.state == HomeLoadState.error) {
              return _ErrorState(
                message: vm.errorMessage ?? 'Terjadi kesalahan',
                onRetry: vm.fetchHomeData,
                primaryColor: vm.primaryColor,
              );
            }
            return Column(
              children: [
                HomeAppBar(
                  roleLabel: vm.roleLabel,
                  accentColor: vm.primaryColor,
                  onNotificationTap: () => vm.onNotificationPressed(context),
                  onSettingsTap: () => vm.onSettingsPressed(context),
                ),
                Expanded(
                  child: RefreshIndicator(
                    color: vm.primaryColor,
                    onRefresh: vm.onRefresh,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _HeaderSection(
                                  profile: vm.data!.profile,
                                  primaryColor: vm.primaryColor,
                                ),
                                SizedBox(height: 54.h),
                                _SummaryRow(
                                  summary: vm.data!.summary,
                                  vm: vm,
                                ),
                                if (vm.data!.buyerMatch.hasMatch) ...[
                                  _MatchCard(
                                    match: vm.data!.buyerMatch,
                                    vm: vm,
                                    onTap: () => vm.onBuyerMatchPressed(context),
                                  ),
                                  SizedBox(height: 16.h),
                                ],
                                _CreatePlanButton(
                                  label: vm.createButtonLabel,
                                  primaryColor: vm.primaryColor,
                                  role: vm.role,
                                ),
                                SizedBox(height: 24.h),
                                _SectionHeader(
                                  title: vm.sectionTitle,
                                  primaryColor: vm.primaryColor,
                                  onSeeAll: () => vm.onSeeAllPlansPressed(context),
                                ),
                                SizedBox(height: 12.h),
                                ...vm.data!.recentPlans.map((plan) {
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 12.h),
                                    child: HarvestPlanCard(
                                      plan: plan,
                                      onTap: () => vm.onPlanCardPressed(context, plan),
                                      role: vm.role
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final FarmerProfileModel profile;
  final Color primaryColor;

  const _HeaderSection({
    required this.profile,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 24.r,
              backgroundColor: AppColors.textSecondary,
              backgroundImage: profile.photoUrl != null
                  ? NetworkImage(profile.photoUrl!)
                  : null,
              child: profile.photoUrl == null
                  ? Icon(
                      Icons.person,
                      color: primaryColor,
                      size: 24.sp,
                    )
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, ${profile.name}! 👋',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    profile.location,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12.5.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final HomeSummaryModel summary;
  final HomeViewModel vm;

  const _SummaryRow({required this.summary, required this.vm});

  @override
  Widget build(BuildContext context) {
    final stat2Value = vm.isPetani
        ? '${summary.totalAllocatedKg.toStringAsFixed(0)} kg'
        : '${summary.totalAllocatedKg.toStringAsFixed(0)}%';

    return Transform.translate(
      offset: Offset(0, -28.h),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.event_available_rounded,
              value: '${summary.activePlans}',
              label: vm.stat1Label,
              primaryColor: vm.primaryColor,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: _StatCard(
              icon: Icons.speed_rounded,
              value: stat2Value,
              label: vm.stat2Label,
              primaryColor: vm.primaryColor,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: _StatCard(
              icon: Icons.swap_vert_rounded,
              value: '${summary.completedTransactions}',
              label: vm.stat3Label,
              primaryColor: vm.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color primaryColor;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 26.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10.5.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final BuyerMatchModel match;
  final HomeViewModel vm;
  final VoidCallback onTap;

  const _MatchCard({
    required this.match,
    required this.vm,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: vm.primaryLightColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: vm.primaryColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vm.matchTitle,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: vm.primaryColor,
                  ),
                ),
                SizedBox(height: 4.h),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      color: AppColors.textSecondary,
                    ),
                    children: [
                      TextSpan(
                        text: '${match.matchCount} ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: vm.primaryColor,
                        ),
                      ),
                      const TextSpan(text: 'kecocokan menunggu konfirmasimu'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: vm.primaryColor,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: Text(
              'Lihat',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreatePlanButton extends StatelessWidget {
  final String label;
  final Color primaryColor;
  final UserRole role;

  const _CreatePlanButton({
    required this.label,
    required this.primaryColor,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52.h,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          final routeName = role == UserRole.petani
              ? '/tambah-rencana'
              : '/rencana-kebutuhan-baru';

          Navigator.pushNamed(context, routeName);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, color: Colors.white, size: 20),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color primaryColor;
  final VoidCallback onSeeAll;

  const _SectionHeader({
    required this.title,
    required this.primaryColor,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        GestureDetector(
          onTap: onSeeAll,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: AppColors.borderDefault),
            ),
            child: Text(
              'Lihat Semua',
              style: TextStyle(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final Color primaryColor;

  const _ErrorState({
    required this.message,
    required this.onRetry,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppColors.textMuted,
            size: 40.sp,
          ),
          SizedBox(height: 12.h),
          Text(
            message,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp),
          ),
          SizedBox(height: 12.h),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: const Text(
              'Coba Lagi',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}