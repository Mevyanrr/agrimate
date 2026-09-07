import 'package:agrimate/core/appcolor.dart';
import 'package:agrimate/role_selection/model/role.dart';
import 'package:agrimate/transaksi/model/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../core/widget/appbar.dart';
import '../../../core/widget/navbar_petani.dart';
import '../viewmodel/transaction_list_vm.dart';

class TransactionListView extends StatelessWidget {
  final UserRole role;
  const TransactionListView({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TransactionListViewModel(role: role),
      child: const _TransactionListBody(),
    );
  }
}

class _TransactionListBody extends StatelessWidget {
  const _TransactionListBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TransactionListViewModel>();
    final accentColor = vm.isPetani
        ? AppColors.greenprimary
        : AppColors.orangeprimary;
    final accentLight = vm.isPetani
        ? AppColors.lightgreen
        : AppColors.lightorange;

    return Scaffold(
      backgroundColor: AppColors.scaffoldGrey,
      bottomNavigationBar: AppBottomNav(
        currentIndex: 3,
        accentColor: accentColor,
        onTap: (index) => vm.onNavTap(context, index),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            HomeAppBar(
              roleLabel: vm.isPetani ? 'Petani' : 'Pembeli',
              accentColor: accentColor,
              onNotificationTap: () =>
                  Navigator.pushNamed(context, '/notifikasi'),
              onSettingsTap: () => Navigator.pushNamed(context, '/pengaturan'),
            ),
            Expanded(
              child: vm.state == TransactionLoadState.loading
                  ? Center(child: CircularProgressIndicator(color: accentColor))
                  : vm.state == TransactionLoadState.error
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.w),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              vm.errorMessage ?? 'Gagal memuat transaksi.',
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 12.h),
                            ElevatedButton(
                              onPressed: vm.fetchTransactions,
                              child: const Text('Coba lagi'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      color: accentColor,
                      onRefresh: vm.onRefresh,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 100.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Transaksi',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 16.h),

                            Row(
                              children: [
                                Expanded(
                                  child: _StatCard(
                                    icon: Icons.event_available_rounded,
                                    accentColor: accentColor,
                                    value: '${vm.summary!.totalTransactions}',
                                    label: 'Total Transaksi',
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: _StatCard(
                                    icon: Icons.check_rounded,
                                    accentColor: accentColor,
                                    value: '${vm.summary!.completedCount}',
                                    label: 'Selesai',
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: _StatCard(
                                    icon: Icons.access_time_rounded,
                                    accentColor: accentColor,
                                    value: '${vm.summary!.waitingCount}',
                                    label: 'Menunggu',
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),

                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: accentLight,
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          vm.totalValueLabel,
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          'Rp ${_formatCurrency(vm.summary!.totalValue)}',
                                          style: TextStyle(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.bold,
                                            color: accentColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(10.w),
                                    decoration: BoxDecoration(
                                      color: accentColor,
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    child: const Icon(
                                      Icons.account_balance_wallet_rounded,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16.h),

                            SizedBox(
                              height: 36.h,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: TransactionFilter.values.length,
                                separatorBuilder: (_, __) =>
                                    SizedBox(width: 8.w),
                                itemBuilder: (context, index) {
                                  final filter =
                                      TransactionFilter.values[index];
                                  final isActive = filter == vm.activeFilter;
                                  return GestureDetector(
                                    onTap: () => vm.onFilterChanged(filter),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                      ),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: isActive
                                            ? accentColor
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(
                                          30.r,
                                        ),
                                        border: Border.all(
                                          color: isActive
                                              ? accentColor
                                              : AppColors.borderDefault,
                                        ),
                                      ),
                                      child: Text(
                                        filter.label,
                                        style: TextStyle(
                                          fontSize: 12.5.sp,
                                          fontWeight: FontWeight.w600,
                                          color: isActive
                                              ? Colors.white
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 16.h),

                            if (vm.filteredTransactions.isEmpty)
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 48.h),
                                child: const Center(
                                  child: Text('Belum ada transaksi.'),
                                ),
                              ),
                            ...vm.filteredTransactions.map((trx) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: 12.h),
                                child: _TransactionCard(
                                  trx: trx,
                                  accentColor: accentColor,
                                  onTap: () =>
                                      vm.onTransactionTapped(context, trx),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double value) {
    final str = value.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i != 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color accentColor;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.accentColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 18.sp),
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

class _TransactionCard extends StatelessWidget {
  final TransactionModel trx;
  final Color accentColor;
  final VoidCallback onTap;

  const _TransactionCard({
    required this.trx,
    required this.accentColor,
    required this.onTap,
  });

  ({Color bg, Color fg}) get _badgeColor {
    switch (trx.status) {
      case TransactionStatus.waiting:
        return (bg: AppColors.amberAccentLight, fg: AppColors.amberAccent);
      case TransactionStatus.confirmed:
        return (bg: AppColors.purpleAccentLight, fg: AppColors.purpleAccent);
      case TransactionStatus.done:
        return (bg: AppColors.lightgreen, fg: AppColors.greenprimary);
      case TransactionStatus.cancelled:
        return (bg: AppColors.redAccentLight, fg: AppColors.redAccent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final badge = _badgeColor;
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.scaffoldGrey,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  trx.commodityEmoji,
                  style: TextStyle(fontSize: 22.sp),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${trx.commodityName} - ${trx.weightKg.toStringAsFixed(0)} kg',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: badge.bg,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            trx.status.shortLabel,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: badge.fg,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      trx.transactionDateLabel,
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      trx.counterpartyLabel,
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Rp ${_formatCurrency(trx.totalPrice)}',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Divider(height: 20.h, color: AppColors.borderDefault),
          GestureDetector(
            onTap: onTap,
            child: Center(
              child: Text(
                'Lihat Selengkapnya',
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    final str = value.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i != 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}
