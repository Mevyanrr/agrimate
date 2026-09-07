import 'package:agrimate/core/appcolor.dart';
import 'package:agrimate/core/widget/navbar_petani.dart';
import 'package:agrimate/core/widget/appbar.dart';
import 'package:agrimate/petani_features/widget/card_rencanapanen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../viewmodel/rencana_panen_vm.dart';

class RencanaPanenView extends StatelessWidget {
  const RencanaPanenView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RencanaPanenViewModel(),
      child: const _RencanaPanenBody(),
    );
  }
}

class _RencanaPanenBody extends StatelessWidget {
  const _RencanaPanenBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RencanaPanenViewModel>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldGrey,
      bottomNavigationBar: AppBottomNav(
        currentIndex: vm.currentNavIndex,
        accentColor: AppColors.greenprimary,
        onTap: (index) => vm.onNavTap(context, index),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
             HomeAppBar(
  roleLabel: 'Petani',
  accentColor: AppColors.greenprimary,
  onNotificationTap: () => vm.onNotificationPressed(context),
  onSettingsTap: () => vm.onSettingsPressed(context),
),
            _RencanaPanenHeader(onAddTap: () => vm.onAddPlanPressed(context)),
            Expanded(child: _buildContent(context, vm)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, RencanaPanenViewModel vm) {
    if (vm.state == RencanaPanenLoadState.loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.greenprimary),
      );
    }
    if (vm.state == RencanaPanenLoadState.error) {
      return _ErrorState(
        message: vm.errorMessage ?? 'Terjadi kesalahan',
        onRetry: vm.fetchRencanaData,
      );
    }

    final plans = vm.data!.plans;

    return RefreshIndicator(
      color: AppColors.greenprimary,
      onRefresh: vm.onRefresh,
      child: plans.isEmpty
          ? _EmptyState(onCreatePlan: () => vm.onAddPlanPressed(context))
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
              itemCount: plans.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final plan = plans[index];
                return HarvestPlanCard(
                  plan: plan,
                  onTap: () => vm.onPlanCardPressed(context, plan),
                );
              },
            ),
    );
  }
}

class _RencanaPanenHeader extends StatelessWidget {
  final VoidCallback onAddTap;
  const _RencanaPanenHeader({required this.onAddTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.scaffoldGrey,
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Rencana Panen Saya',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Material(
            color: AppColors.greenprimary,
            borderRadius: BorderRadius.circular(12.r),
            child: InkWell(
              borderRadius: BorderRadius.circular(12.r),
             onTap: () { Navigator.pushNamed( context, '/tambah-rencana', ); },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                child: 
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Tambah',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        )),
                    Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 22.sp,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreatePlan;
  const _EmptyState({required this.onCreatePlan});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.event_note_rounded,
                      color: AppColors.textMuted,
                      size: 48.sp,
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      'Belum ada rencana panen',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Buat rencana panen pertamamu untuk mulai terhubung dengan pembeli.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 18.h),
                    ElevatedButton(
                      onPressed: onCreatePlan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.greenprimary,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 12.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        '+ Buat Rencana Panen Baru',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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