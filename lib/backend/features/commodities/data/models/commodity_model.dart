import '../../domain/entities/commodity.dart';

class CommodityModel extends Commodity {
  const CommodityModel({
    required super.id,
    required super.name,
    required super.unit,
    required super.price,
    required super.source,
    super.sourcePeriod,
    super.sourceDate,
    super.priceSourceName,
  });

  factory CommodityModel.fromJson(Map<String, dynamic> json) => CommodityModel(
    id: json['commodity_id'].toString(),
    name: json['name'] as String,
    unit: json['unit'] as String,
    price: (json['price'] as num).toDouble(),
    source: json['source'] as String,
    sourcePeriod: json['source_period'] as String?,
    sourceDate: json['source_date'] == null
        ? null
        : DateTime.parse(json['source_date'] as String),
    priceSourceName: json['price_source_name'] as String?,
  );
}
