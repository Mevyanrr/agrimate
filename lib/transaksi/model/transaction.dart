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
    final commodity = json['commodity'] is Map
        ? Map<String, dynamic>.from(json['commodity'] as Map)
        : const <String, dynamic>{};
    final quantity = _number(json, const [
      'weight_kg',
      'quantity_kg',
      'matched_quantity',
      'quantity',
    ]);
    final unitPrice = _number(json, const ['unit_price', 'price_per_kg']);
    final subtotal = _number(json, const [
      'subtotal',
    ], fallback: quantity * unitPrice);
    final totalPrice = _number(json, const [
      'total_price',
      'total_amount',
    ], fallback: subtotal);
    final serviceFee = _number(json, const ['service_fee']);

    return TransactionModel(
      id: json['id']?.toString() ?? '',
      commodityName:
          json['commodity_name']?.toString() ??
          commodity['name']?.toString() ??
          'Komoditas',
      commodityEmoji:
          json['commodity_emoji']?.toString() ??
          _commodityEmoji(commodity['name']?.toString()),
      weightKg: quantity,
      transactionDateLabel:
          json['transaction_date_label']?.toString() ??
          _dateLabel(json['created_at']),
      counterpartyLabel: json['counterparty_label'] as String? ?? '-',
      totalPrice: totalPrice,
      status: _transactionStatus(json['status']),
      unitPrice: unitPrice,
      subtotal: subtotal,
      serviceFeePercent: (json['service_fee_percent'] as num?)?.toDouble() ?? 5,
      serviceFee: serviceFee,
      totalReceived: _number(json, const [
        'total_received',
      ], fallback: totalPrice - serviceFee),
      deliveryDateLabel:
          json['delivery_date_label']?.toString() ??
          _nullableDateLabel(json['delivery_date']),
      deliveryAddress: json['delivery_address']?.toString(),
      cancelDateLabel:
          json['cancel_date_label']?.toString() ??
          _nullableDateLabel(json['cancelled_at']),
      cancelReason: json['cancel_reason']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
      whatsappNumber: json['whatsapp_number']?.toString(),
      ratingGiven: (json['rating_given'] as num?)?.toDouble(),
    );
  }
}

double _number(
  Map<String, dynamic> json,
  List<String> keys, {
  double fallback = 0,
}) {
  for (final key in keys) {
    final value = json[key];
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
  }
  return fallback;
}

TransactionStatus _transactionStatus(Object? value) {
  switch (value?.toString().toUpperCase()) {
    case 'CONFIRMED':
    case 'AGREED':
    case 'IN_PROGRESS':
      return TransactionStatus.confirmed;
    case 'DONE':
    case 'COMPLETED':
      return TransactionStatus.done;
    case 'CANCELLED':
    case 'CANCELED':
    case 'REJECTED':
      return TransactionStatus.cancelled;
    default:
      return TransactionStatus.waiting;
  }
}

String _commodityEmoji(String? name) {
  final value = name?.toLowerCase() ?? '';
  if (value.contains('tomat')) return '🍅';
  if (value.contains('cabai')) return '🌶️';
  if (value.contains('jagung')) return '🌽';
  if (value.contains('bawang')) return '🧅';
  if (value.contains('bayam') || value.contains('sawi')) return '🥬';
  return '🌾';
}

String _dateLabel(Object? value) => _nullableDateLabel(value) ?? '-';

String? _nullableDateLabel(Object? value) {
  final date = value is DateTime
      ? value
      : DateTime.tryParse(value?.toString() ?? '');
  if (date == null) return null;
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
  return '${date.day} ${months[date.month - 1]} ${date.year}';
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
