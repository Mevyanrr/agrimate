enum BuyerType { restoran, distributor, catering, koperasi }

extension BuyerTypeX on BuyerType {
  String get label {
    switch (this) {
      case BuyerType.restoran:
        return 'Restoran';
      case BuyerType.distributor:
        return 'Distributor';
      case BuyerType.catering:
        return 'Catering';
      case BuyerType.koperasi:
        return 'Koperasi';
    }
  }

  static BuyerType fromString(String? value) {
    switch (value) {
      case 'distributor':
        return BuyerType.distributor;
      case 'catering':
        return BuyerType.catering;
      case 'koperasi':
        return BuyerType.koperasi;
      case 'restoran':
      default:
        return BuyerType.restoran;
    }
  }
}

class CommodityFilterModel {
  final String id;
  final String label;

  const CommodityFilterModel({required this.id, required this.label});

  factory CommodityFilterModel.fromJson(Map<String, dynamic> json) {
    return CommodityFilterModel(
      id: json['id'] as String,
      label: json['label'] as String? ?? '-',
    );
  }
}

enum PasarTimelineFilter { semua, mingguIni, bulanIni }

extension PasarTimelineFilterX on PasarTimelineFilter {
  String get label {
    switch (this) {
      case PasarTimelineFilter.semua:
        return 'Semua Waktu';
      case PasarTimelineFilter.mingguIni:
        return 'Minggu Ini';
      case PasarTimelineFilter.bulanIni:
        return 'Bulan Ini';
    }
  }
}

class BuyerRequestModel {
  final String id;
  final String commodityId;
  final String commodityName;
  final String commodityEmoji;
  final BuyerType buyerType;
  final String buyerName;
  final String location;
  final double quantityKg;
  final String periodLabel;
  final double pricePerKg;
  final DateTime neededDate;
  final bool isApplied;
   final String frequencyLabel;
  final String description;

  const BuyerRequestModel({
    required this.id,
    required this.commodityId,
    required this.commodityName,
    required this.commodityEmoji,
    required this.buyerType,
    required this.buyerName,
    required this.location,
    required this.quantityKg,
    required this.periodLabel,
    required this.pricePerKg,
    required this.neededDate,
    this.isApplied = false,
    required this.frequencyLabel,
    required this.description,
  });

  factory BuyerRequestModel.fromJson(Map<String, dynamic> json) {
    return BuyerRequestModel(
      id: json['id'] as String,
      commodityId: json['commodity_id'] as String? ?? '-',
      commodityName: json['commodity_name'] as String? ?? '-',
      commodityEmoji: json['commodity_emoji'] as String? ?? '🌾',
      buyerType: BuyerTypeX.fromString(json['buyer_type'] as String?),
      buyerName: json['buyer_name'] as String? ?? '-',
      location: json['location'] as String? ?? '-',
      quantityKg: (json['quantity_kg'] as num?)?.toDouble() ?? 0,
      periodLabel: json['period_label'] as String? ?? '-',
      pricePerKg: (json['price_per_kg'] as num?)?.toDouble() ?? 0,
      neededDate: DateTime.tryParse(json['needed_date'] as String? ?? '') ??
          DateTime.now(),
      isApplied: json['is_applied'] as bool? ?? false,
      frequencyLabel: json['frequency_label'] as String? ?? '-',
      description: json['description'] as String? ?? '-',
    );
  }

  BuyerRequestModel copyWith({bool? isApplied}) {
    return BuyerRequestModel(
      id: id,
      commodityId: commodityId,
      commodityName: commodityName,
      commodityEmoji: commodityEmoji,
      buyerType: buyerType,
      buyerName: buyerName,
      location: location,
      quantityKg: quantityKg,
      periodLabel: periodLabel,
      pricePerKg: pricePerKg,
      neededDate: neededDate,
      isApplied: isApplied ?? this.isApplied,
      frequencyLabel: frequencyLabel,
      description: description,
    );
  }
}