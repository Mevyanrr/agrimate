import '../../domain/entities/commodity.dart';

class CommodityModel extends Commodity {
  const CommodityModel({
    required super.id,
    required super.name,
    required super.isActive,
  });

  factory CommodityModel.fromJson(Map<String, dynamic> json) => CommodityModel(
    id: json['id'].toString(),
    name: json['name'] as String,
    isActive: json['is_active'] as bool? ?? false,
  );
}

class CommodityPriceModel extends CommodityPrice {
  const CommodityPriceModel({
    required super.id,
    required super.commodityId,
    required super.price,
    required super.marketLevel,
    required super.regionLevel,
    required super.sourceDate,
  });

  factory CommodityPriceModel.fromJson(Map<String, dynamic> json) {
    return CommodityPriceModel(
      id: json['id'].toString(),
      commodityId: json['commodity_id'].toString(),
      // TODO: Ganti `price` jika nama kolom harga di database berbeda.
      price: json['price'] as num,
      marketLevel: json['market_level'] as String,
      regionLevel: json['region_level'] as String,
      sourceDate: DateTime.parse(json['source_date'] as String),
    );
  }
}
