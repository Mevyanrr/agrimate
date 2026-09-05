class Commodity {
  const Commodity({
    required this.id,
    required this.name,
    required this.unit,
    required this.price,
    required this.source,
    this.sourcePeriod,
    this.sourceDate,
    this.priceSourceName,
  });

  final String id;
  final String name;
  final String unit;
  final double price;
  final String source;
  final String? sourcePeriod;
  final DateTime? sourceDate;
  final String? priceSourceName;
}
