class SupplyForecast {
  const SupplyForecast({
    this.id,
    this.farmerId,
    required this.commodityId,
    required this.quantity,
    this.remainingQuantity,
    required this.harvestStartDate,
    required this.harvestEndDate,
    required this.address,
    this.latitude,
    this.longitude,
    this.status,
    this.province,
    this.city,
    this.district,
    this.farmerName,
  });

  final String? id;
  final String? farmerId;
  final String commodityId;
  final num quantity;
  final num? remainingQuantity;
  final DateTime harvestStartDate;
  final DateTime harvestEndDate;
  final String address;
  final double? latitude;
  final double? longitude;
  final String? status;
  final String? province;
  final String? city;
  final String? district;
  final String? farmerName;
}
