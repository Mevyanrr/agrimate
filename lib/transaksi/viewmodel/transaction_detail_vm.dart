import 'package:agrimate/role_selection/model/role.dart';
import 'package:agrimate/transaksi/model/transaction.dart';
import 'package:agrimate/transaksi/view/rating_sheet.dart';
import 'package:flutter/material.dart';

class TransactionDetailViewModel extends ChangeNotifier {
  final UserRole role;
  TransactionModel transaction;

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
    final rating = await showRatingSheet(context, accentColor: accentColor);
    if (rating == null) return;


    transaction = transaction.copyWith(ratingGiven: rating);
    notifyListeners();
  }

  void onCallPressed(BuildContext context) {
    debugPrint('Telepon ke ${transaction.phoneNumber}');
  }

  void onWhatsappPressed(BuildContext context) {
    debugPrint('WhatsApp ke ${transaction.whatsappNumber}');
  }

  void onBackPressed(BuildContext context) {
    Navigator.pop(context, transaction); 
  }
}