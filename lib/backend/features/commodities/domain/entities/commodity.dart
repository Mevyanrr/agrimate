class Commodity {
  const Commodity({required this.id, required this.name, required this.isActive});

  final String id;
  final String name;
  final bool isActive;
}

class CommodityPrice {
  const CommodityPrice({
    required this.id,
    required this.commodityId,
    required this.price,
    required this.marketLevel,
    required this.regionLevel,
    required this.sourceDate,
  });

  final String id;
  final String commodityId;
  final num price;
  final String marketLevel;
  final String regionLevel;
  final DateTime sourceDate;
}
