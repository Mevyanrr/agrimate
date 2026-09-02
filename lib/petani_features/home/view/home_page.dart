import 'package:agrimate/core/appcolor.dart';
import 'package:agrimate/core/widget/navbar_petani.dart';
import 'package:agrimate/petani_features/home/model/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../viewmodel/home_vm.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
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
        accentColor: AppColors.greenprimary,
        onTap: (index) => vm.onNavTap(context, index),
      ),
      body: SafeArea(
        bottom: false,
        child: Builder(
          builder: (context) {
            if (vm.state == HomeLoadState.loading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.greenprimary),
              );
            }
            if (vm.state == HomeLoadState.error) {
              return _ErrorState(
                message: vm.errorMessage ?? 'Terjadi kesalahan',
                onRetry: vm.fetchHomeData,
              );
            }
            return Column(
              
              children: [
                Container(
                      padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 0),
                      decoration: const BoxDecoration(
                        color: AppColors.greenprimary,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 36.w,
                            height: 36.w,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            // padding: EdgeInsets.all(4.w),
                            child: Image.asset(
                              'assets/images/logo_withoutname.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Padding(padding:  EdgeInsets.only(bottom: 8.h),
                          child:
                          Column(
                            
                            children: [
                              Text(
                                'AgriMate',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // SizedBox(height: 8.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 3.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Text(
                                  'Petani',
                                  style: TextStyle(
                                    color: AppColors.greenprimary,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          )
                          ),

                          // const Spacer(),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () =>
                                    vm.onNotificationPressed(context),
                                icon: const Icon(
                                  Icons.notifications_none_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              IconButton(
                                onPressed: () => vm.onSettingsPressed(context),
                                icon: const Icon(
                                  Icons.settings_outlined,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(child: 
            RefreshIndicator(
              color: AppColors.greenprimary,
              onRefresh: vm.onRefresh,
              child: 
              SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        // crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _HeaderSection(profile: vm.data!.profile),
                          SizedBox(height: 54.h),
                          _SummaryRow(summary: vm.data!.summary),

                          if (vm.data!.buyerMatch.hasMatch) ...[
                            _BuyerMatchCard(
                              match: vm.data!.buyerMatch,
                              onTap: () => vm.onBuyerMatchPressed(context),
                            ),
                            SizedBox(height: 16.h),
                          ],
                          _CreatePlanButton(
                            onTap: () => vm.onCreatePlanPressed(context),
                          ),
                          SizedBox(height: 24.h),
                          _SectionHeader(
                            title: 'Rencana Panen Terakhir',
                            onSeeAll: () => vm.onSeeAllPlansPressed(context),
                          ),
                          SizedBox(height: 12.h),
                          ...vm.data!.recentPlans.map((plan) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: _HarvestPlanCard(
                                plan: plan,
                                onTap: () =>
                                    vm.onPlanCardPressed(context, plan),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ), )
            ] );
          },
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final FarmerProfileModel profile;
  const _HeaderSection({required this.profile});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<HomeViewModel>();

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
                      color: AppColors.greenprimary,
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
  const _SummaryRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, -28.h),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.event_available_rounded,
              value: '${summary.activePlans}',
              label: 'Rencana Aktif',
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: _StatCard(
              icon: Icons.scale_rounded,
              value: '${summary.totalAllocatedKg.toStringAsFixed(0)} kg',
              label: 'Total Teralokasi',
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: _StatCard(
              icon: Icons.swap_vert_rounded,
              value: '${summary.completedTransactions}',
              label: 'Transaksi Selesai',
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

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
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
            decoration: const BoxDecoration(
              color: AppColors.greenprimary,
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

class _BuyerMatchCard extends StatelessWidget {
  final BuyerMatchModel match;
  final VoidCallback onTap;

  const _BuyerMatchCard({required this.match, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.lightgreen,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.greenprimary),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ada pembeli yang cocok, nih!',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.greenprimary,
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
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.greenprimary,
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
              backgroundColor: AppColors.darkgreen,
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
  final VoidCallback onTap;
  const _CreatePlanButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52.h,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.greenprimary,
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
              'Buat Rencana Panen Baru',
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
  final VoidCallback onSeeAll;

  const _SectionHeader({required this.title, required this.onSeeAll});

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
                color: AppColors.greenprimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HarvestPlanCard extends StatelessWidget {
  final HarvestPlanModel plan;
  final VoidCallback onTap;

  const _HarvestPlanCard({required this.plan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  plan.dateRangeLabel,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (plan.hasMatch)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.purpleAccentLight,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      'Ada Kecocokan',
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.purpleAccent,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.scaffoldGrey,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    plan.commodityEmoji,
                    style: TextStyle(fontSize: 22.sp),
                  ),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.commodityName,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${plan.totalWeightKg.toStringAsFixed(0)}kg',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.greenprimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Teralokasi',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${plan.allocatedWeightKg.toStringAsFixed(0)}/${plan.totalWeightKg.toStringAsFixed(0)}kg',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: LinearProgressIndicator(
                value: plan.progress,
                minHeight: 6.h,
                backgroundColor: AppColors.indicatorInactive,
                valueColor: const AlwaysStoppedAnimation(
                  AppColors.purpleAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.greenprimary,
            ),
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
