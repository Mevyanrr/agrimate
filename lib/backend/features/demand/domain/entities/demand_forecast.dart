class DemandForecast {
  const DemandForecast({
    this.id,
    this.buyerId,
    required this.commodityId,
    required this.quantity,
    this.remainingQuantity,
    required this.neededStartDate,
    required this.neededEndDate,
    required this.deliveryAddress,
    this.latitude,
    this.longitude,
    this.forecastSource = 'MANUAL',
    this.status,
    this.province,
    this.city,
    this.district,
    this.buyerName,
  });
  final String? id;
  final String? buyerId;
  final String commodityId;
  final num quantity;
  final num? remainingQuantity;
  final DateTime neededStartDate;
  final DateTime neededEndDate;
  final String deliveryAddress;
  final double? latitude;
  final double? longitude;
  final String forecastSource;
  final String? status;
  final String? province;
  final String? city;
  final String? district;
  final String? buyerName;
}
