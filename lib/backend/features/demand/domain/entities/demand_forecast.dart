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
    this.status,
  });
  final String? id;
  final String? buyerId;
  final String commodityId;
  final num quantity;
  final num? remainingQuantity;
  final DateTime neededStartDate;
  final DateTime neededEndDate;
  final String deliveryAddress;
  final String? status;
}
