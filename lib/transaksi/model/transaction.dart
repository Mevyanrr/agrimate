enum TransactionStatus { waiting, confirmed, done, cancelled }

extension TransactionStatusX on TransactionStatus {
  String get label {
    switch (this) {
      case TransactionStatus.waiting:
        return 'Menunggu Konfirmasi';
      case TransactionStatus.confirmed:
        return 'Dikonfirmasi';
      case TransactionStatus.done:
        return 'Selesai';
      case TransactionStatus.cancelled:
        return 'Batal';
    }
  }

  String get shortLabel {
    switch (this) {
      case TransactionStatus.waiting:
        return 'Menunggu Konfirmasi';
      case TransactionStatus.confirmed:
        return 'Dikonfirmasi';
      case TransactionStatus.done:
        return 'Selesai';
      case TransactionStatus.cancelled:
        return 'Batal';
    }
  }
  int get stepIndex {
    switch (this) {
      case TransactionStatus.waiting:
        return 1;
      case TransactionStatus.confirmed:
        return 2;
      case TransactionStatus.done:
        return 3;
      case TransactionStatus.cancelled:
        return 2;
    }
  }
}

class TransactionModel {
  final String id;
  final String commodityName;
  final String commodityEmoji;
  final double weightKg;
  final String transactionDateLabel; 
  final String counterpartyLabel;  
  final double totalPrice;
  final TransactionStatus status;

  // Detail breakdown harga
  final double unitPrice;
  final double subtotal;
  final double serviceFeePercent;
  final double serviceFee;
  final double totalReceived;

  // Info pengiriman (waiting/confirmed/done)
  final String? deliveryDateLabel;
  final String? deliveryAddress;

  // Info pembatalan (cancelled)
  final String? cancelDateLabel;
  final String? cancelReason;

  // Kontak counterparty
  final String? phoneNumber;
  final String? whatsappNumber;

  // Rating yang sudah diberikan (null kalau belum)
  final double? ratingGiven;

  const TransactionModel({
    required this.id,
    required this.commodityName,
    required this.commodityEmoji,
    required this.weightKg,
    required this.transactionDateLabel,
    required this.counterpartyLabel,
    required this.totalPrice,
    required this.status,
    required this.unitPrice,
    required this.subtotal,
    required this.serviceFeePercent,
    required this.serviceFee,
    required this.totalReceived,
    this.deliveryDateLabel,
    this.deliveryAddress,
    this.cancelDateLabel,
    this.cancelReason,
    this.phoneNumber,
    this.whatsappNumber,
    this.ratingGiven,
  });

  TransactionModel copyWith({double? ratingGiven}) {
    return TransactionModel(
      id: id,
      commodityName: commodityName,
      commodityEmoji: commodityEmoji,
      weightKg: weightKg,
      transactionDateLabel: transactionDateLabel,
      counterpartyLabel: counterpartyLabel,
      totalPrice: totalPrice,
      status: status,
      unitPrice: unitPrice,
      subtotal: subtotal,
      serviceFeePercent: serviceFeePercent,
      serviceFee: serviceFee,
      totalReceived: totalReceived,
      deliveryDateLabel: deliveryDateLabel,
      deliveryAddress: deliveryAddress,
      cancelDateLabel: cancelDateLabel,
      cancelReason: cancelReason,
      phoneNumber: phoneNumber,
      whatsappNumber: whatsappNumber,
      ratingGiven: ratingGiven ?? this.ratingGiven,
    );
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      commodityName: json['commodity_name'] as String? ?? '-',
      commodityEmoji: json['commodity_emoji'] as String? ?? '🌾',
      weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 0,
      transactionDateLabel: json['transaction_date_label'] as String? ?? '-',
      counterpartyLabel: json['counterparty_label'] as String? ?? '-',
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0,
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TransactionStatus.waiting,
      ),
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      serviceFeePercent: (json['service_fee_percent'] as num?)?.toDouble() ?? 5,
      serviceFee: (json['service_fee'] as num?)?.toDouble() ?? 0,
      totalReceived: (json['total_received'] as num?)?.toDouble() ?? 0,
      deliveryDateLabel: json['delivery_date_label'] as String?,
      deliveryAddress: json['delivery_address'] as String?,
      cancelDateLabel: json['cancel_date_label'] as String?,
      cancelReason: json['cancel_reason'] as String?,
      phoneNumber: json['phone_number'] as String?,
      whatsappNumber: json['whatsapp_number'] as String?,
      ratingGiven: (json['rating_given'] as num?)?.toDouble(),
    );
  }
}

class TransactionSummaryModel {
  final int totalTransactions;
  final int completedCount;
  final int waitingCount;
  final double totalValue;

  const TransactionSummaryModel({
    required this.totalTransactions,
    required this.completedCount,
    required this.waitingCount,
    required this.totalValue,
  });

  factory TransactionSummaryModel.fromJson(Map<String, dynamic> json) {
    return TransactionSummaryModel(
      totalTransactions: json['total_transactions'] as int? ?? 0,
      completedCount: json['completed_count'] as int? ?? 0,
      waitingCount: json['waiting_count'] as int? ?? 0,
      totalValue: (json['total_value'] as num?)?.toDouble() ?? 0,
    );
  }
}

enum TransactionFilter { all, waiting, confirmed, cancelled }

extension TransactionFilterX on TransactionFilter {
  String get label {
    switch (this) {
      case TransactionFilter.all:
        return 'Semua';
      case TransactionFilter.waiting:
        return 'Menunggu';
      case TransactionFilter.confirmed:
        return 'Dikonfirmasi';
      case TransactionFilter.cancelled:
        return 'Batal';
    }
  }

  bool matches(TransactionStatus status) {
    switch (this) {
      case TransactionFilter.all:
        return true;
      case TransactionFilter.waiting:
        return status == TransactionStatus.waiting;
      case TransactionFilter.confirmed:
        return status == TransactionStatus.confirmed;
      case TransactionFilter.cancelled:
        return status == TransactionStatus.cancelled;
    }
  }
}