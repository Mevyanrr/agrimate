import 'package:agrimate/backend/backend_dependencies.dart';
import 'package:agrimate/backend/core/result/result.dart';
import 'package:agrimate/role_selection/model/role.dart';
import 'package:agrimate/transaksi/model/transaction.dart';
import 'package:agrimate/transaksi/view/rating_sheet.dart';
import 'package:agrimate/transaksi/view/rating_success_sheet.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TransactionDetailViewModel extends ChangeNotifier {
  static const _fallbackContactPhone = '081234567890';

  final UserRole role;
  TransactionModel transaction;
  final _backend = BackendDependencies.create();

  TransactionDetailViewModel({required this.role, required this.transaction});

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  bool get isPetani => role == UserRole.petani;

  Future<void> onConfirmPressed(BuildContext context) async {
    _isSubmitting = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    transaction = TransactionModel(
      id: transaction.id,
      commodityName: transaction.commodityName,
      commodityEmoji: transaction.commodityEmoji,
      weightKg: transaction.weightKg,
      transactionDateLabel: transaction.transactionDateLabel,
      counterpartyLabel: transaction.counterpartyLabel,
      totalPrice: transaction.totalPrice,
      status: TransactionStatus.confirmed,
      unitPrice: transaction.unitPrice,
      subtotal: transaction.subtotal,
      serviceFeePercent: transaction.serviceFeePercent,
      serviceFee: transaction.serviceFee,
      totalReceived: transaction.totalReceived,
      deliveryDateLabel: transaction.deliveryDateLabel,
      deliveryAddress: transaction.deliveryAddress,
      phoneNumber: transaction.phoneNumber,
      whatsappNumber: transaction.whatsappNumber,
    );

    _isSubmitting = false;
    notifyListeners();
  }

  Future<void> onRatePressed(BuildContext context, Color accentColor) async {
    final rating = await showRatingSheet(
      context,
      accentColor: accentColor,
      transactionId: transaction.id,
    );
    if (rating == null) return;

    transaction = transaction.copyWith(ratingGiven: rating);
    notifyListeners();
    if (context.mounted) await showRatingSuccessSheet(context);
  }

  Future<void> onCallPressed(BuildContext context) async {
    final phone = _normalizedPhone(transaction.phoneNumber);
    if (phone == null) {
      _showContactError(context, 'Nomor telepon belum tersedia.');
      return;
    }
    final opened = await launchUrl(Uri(scheme: 'tel', path: phone));
    if (!opened && context.mounted) {
      _showContactError(context, 'Tidak dapat membuka aplikasi telepon.');
    } else if (opened) {
      if (!context.mounted) return;
      await _completeAfterContact(context);
    }
  }

  Future<void> onWhatsappPressed(BuildContext context) async {
    final phone = _normalizedPhone(transaction.whatsappNumber);
    if (phone == null) {
      _showContactError(context, 'Nomor WhatsApp belum tersedia.');
      return;
    }
    final whatsappNumber = phone.startsWith('+') ? phone.substring(1) : phone;
    final opened = await launchUrl(
      Uri.parse('https://wa.me/$whatsappNumber'),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) {
      _showContactError(context, 'Tidak dapat membuka WhatsApp.');
    } else if (opened) {
      if (!context.mounted) return;
      await _completeAfterContact(context);
    }
  }

  Future<void> _completeAfterContact(BuildContext context) async {
    if (transaction.status == TransactionStatus.done) return;
    final result = await _backend.transactions.complete(transaction.id);
    if (result is Success<void>) {
      transaction = transaction.copyWith(
        status: TransactionStatus.done,
        deliveryDateLabel: _todayLabel(),
      );
      notifyListeners();
      return;
    }
    if (result case Failure(message: final message)) {
      if (context.mounted) {
        _showContactError(
          context,
          'Kontak terbuka, tetapi status gagal diperbarui: $message',
        );
      }
    }
  }

  String? _normalizedPhone(String? raw) {
    final digits = (raw ?? _fallbackContactPhone).replaceAll(
      RegExp(r'[^0-9+]'),
      '',
    );
    if (digits.isEmpty) return null;
    if (digits.startsWith('+62')) return digits;
    if (digits.startsWith('62')) return '+$digits';
    if (digits.startsWith('0')) return '+62${digits.substring(1)}';
    return digits.startsWith('+') ? digits : '+$digits';
  }

  String _todayLabel() {
    final now = DateTime.now();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  void _showContactError(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void onBackPressed(BuildContext context) {
    Navigator.pop(context, transaction);
  }
}
