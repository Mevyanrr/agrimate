import 'package:agrimate/core/appcolor.dart';
import 'package:agrimate/role_selection/model/role.dart';
import 'package:agrimate/transaksi/model/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../viewmodel/transaction_detail_vm.dart';

class TransactionDetailView extends StatelessWidget {
  final UserRole role;
  final TransactionModel transaction;

  const TransactionDetailView({super.key, required this.role, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TransactionDetailViewModel(role: role, transaction: transaction),
      child: const _DetailBody(),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TransactionDetailViewModel>();
    final trx = vm.transaction;
    final accentColor = vm.isPetani ? AppColors.greenprimary : AppColors.orangeprimary;
    final inactiveAccentColor = vm.isPetani ? AppColors.lightgreen : AppColors.lightorange;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) vm.onBackPressed(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => vm.onBackPressed(context),
          ),
          title: Text('Detail Transaksi',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 16.sp, fontWeight: FontWeight.bold)),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: _borderColorFor(trx.status)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48.w,
                        height: 48.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: AppColors.scaffoldGrey, borderRadius: BorderRadius.circular(12.r)),
                        child: Text(trx.commodityEmoji, style: TextStyle(fontSize: 24.sp)),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${trx.commodityName} - ${trx.weightKg.toStringAsFixed(0)} kg',
                                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                  ),
                                ),
                                _StatusBadge(status: trx.status),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Text(trx.transactionDateLabel, style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
                            Text(trx.counterpartyLabel, style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('Rp ${_formatCurrency(trx.totalPrice)}',
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  ),
                  SizedBox(height: 20.h),

                  _StepperRow(
                    currentStep: trx.status.stepIndex,
                    isCancelled: trx.status == TransactionStatus.cancelled,
                    activeColor: accentColor,
                    inactiveColor: inactiveAccentColor,
                  ),
                  SizedBox(height: 20.h),

                  _PriceRow(label: 'Harga Satuan', value: 'Rp ${_formatCurrency(trx.unitPrice)}/kg'),
                  SizedBox(height: 8.h),
                  _PriceRow(label: 'Subtotal', value: 'Rp ${_formatCurrency(trx.subtotal)}/kg'),
                  SizedBox(height: 8.h),
                  _PriceRow(
                    label: 'Biaya Layanan (${trx.serviceFeePercent.toStringAsFixed(0)}%)',
                    value: 'Rp ${_formatCurrency(trx.serviceFee)}',
                    valueColor: AppColors.amberAccent,
                  ),
                  Divider(height: 24.h, color: AppColors.borderDefault),
                  _PriceRow(
                    label: 'Total Diterima',
                    value: 'Rp ${_formatCurrency(trx.totalReceived)}',
                    isBold: true,
                  ),
                  SizedBox(height: 16.h),

                  if (trx.status == TransactionStatus.cancelled)
                    _InfoBox(
                      title: 'Info Pembatalan',
                      lines: ['Tanggal: ${trx.cancelDateLabel}', 'Alasan: ${trx.cancelReason}'],
                    )
                  else
                    _InfoBox(
                      title: 'Info Pengiriman',
                      lines: ['Tanggal: ${trx.deliveryDateLabel}', 'Alamat: ${trx.deliveryAddress}'],
                    ),
                  SizedBox(height: 16.h),

                  if (trx.status != TransactionStatus.cancelled)
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 46.h,
                            child: OutlinedButton.icon(
                              onPressed: () => vm.onCallPressed(context),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.borderDefault),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                              ),
                              icon: Icon(Icons.call_outlined, size: 16.sp, color: AppColors.textPrimary),
                              label: Text('Telepon', style: TextStyle(fontSize: 13.sp, color: AppColors.textPrimary)),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: SizedBox(
                            height: 46.h,
                            child: OutlinedButton.icon(
                              onPressed: () => vm.onWhatsappPressed(context),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: accentColor.withOpacity(0.08),
                                side: BorderSide(color: accentColor),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                              ),
                              icon: Image.asset('assets/images/whatsapp.png', width: 16.w, height: 16.w),
                              label: Text('WhatsApp', style: TextStyle(fontSize: 13.sp, color: accentColor)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 16.h),

                  if (trx.status == TransactionStatus.waiting)
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: vm.isSubmitting ? null : () => vm.onConfirmPressed(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                        ),
                        child: vm.isSubmitting
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text('Konfirmasi Kesepakatan',
                                style: TextStyle(color: Colors.white, fontSize: 14.5.sp, fontWeight: FontWeight.w600)),
                      ),
                    )
                  else if (trx.status == TransactionStatus.done)
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: OutlinedButton.icon(
                        onPressed: trx.ratingGiven != null ? null : () => vm.onRatePressed(context, accentColor),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.goldButtonBg,
                          side: BorderSide(color: AppColors.goldStar),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                        ),
                        icon: Icon(Icons.star_rounded, color: AppColors.goldStar),
                        label: Text(
                          trx.ratingGiven != null
                              ? 'Sudah Dinilai (${trx.ratingGiven!.toStringAsFixed(0)} ⭐)'
                              : 'Beri Penilaian',
                          style: TextStyle(fontSize: 14.5.sp, fontWeight: FontWeight.bold, color: AppColors.goldStar),
                        ),
                      ),
                    )
                  else if (trx.status == TransactionStatus.cancelled)
                    Center(
                      child: Text('Pesanan dibatalkan',
                          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.redAccent)),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _borderColorFor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.waiting:
        return AppColors.amberAccent.withOpacity(0.4);
      case TransactionStatus.confirmed:
        return AppColors.purpleAccent.withOpacity(0.4);
      case TransactionStatus.done:
        return AppColors.greenprimary.withOpacity(0.4);
      case TransactionStatus.cancelled:
        return AppColors.redAccent.withOpacity(0.4);
    }
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

class _StatusBadge extends StatelessWidget {
  final TransactionStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    late Color bg, fg;
    switch (status) {
      case TransactionStatus.waiting:
        bg = AppColors.amberAccentLight; fg = AppColors.amberAccent; break;
      case TransactionStatus.confirmed:
        bg = AppColors.purpleAccentLight; fg = AppColors.purpleAccent; break;
      case TransactionStatus.done:
        bg = AppColors.lightgreen; fg = AppColors.greenprimary; break;
      case TransactionStatus.cancelled:
        bg = AppColors.redAccentLight; fg = AppColors.redAccent; break;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20.r)),
      child: Text(status.label, style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}


class _StepperRow extends StatelessWidget {
  final int currentStep;
  final bool isCancelled;
  final Color activeColor;
  final Color inactiveColor;

  const _StepperRow({
    super.key,
    required this.currentStep,
    required this.isCancelled,
    required this.activeColor,
    required this.inactiveColor,
  });

  static const _labels = ['Pengajuan', 'Dikonfirmasi', 'Selesai'];

  @override
  Widget build(BuildContext context) {
    const double circleSize = 26.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(3, (index) {
        final step = index + 1;
        final isDone = step <= currentStep;
        final isLast = index == 2;

        return Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: circleSize.w,
                      height: circleSize.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isDone ? activeColor : inactiveColor,
                        shape: BoxShape.circle,
                      ),
                      child: isDone
                          ? Icon(Icons.check, color: Colors.white, size: 15.sp)
                          : Text(
                              '$step',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: activeColor,
                              ),
                            ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      _labels[index],
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isDone ? activeColor : inactiveColor,
                        fontWeight: isDone ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

if (!isLast)
  Expanded(
    child: Container(
      height: 2.h,
      margin: EdgeInsets.only(
        top: (circleSize.w / 2) - 1.h, 
        left: 4.w,                   
        right: 4.w,
      ),
      color: step < currentStep ? activeColor : inactiveColor,
    ),
  ),
            ],
          ),
        );
      }),
    );
  }
}


class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _PriceRow({required this.label, required this.value, this.valueColor, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 12.5.sp, color: AppColors.textSecondary)),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 14.sp : 12.5.sp,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String title;
  final List<String> lines;
  const _InfoBox({required this.title, required this.lines});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(color: AppColors.scaffoldGrey, borderRadius: BorderRadius.circular(12.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          SizedBox(height: 6.h),
          ...lines.map((l) => Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: Text(l, style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
              )),
        ],
      ),
    );
  }
}