class DemandPrediction {
  const DemandPrediction({
    required this.buyerId,
    required this.buyerName,
    required this.commodityId,
    required this.commodityName,
    required this.commodityUnit,
    required this.predictionPeriod,
    required this.predictedQuantity,
    required this.historyCount,
    required this.latestQuantity,
    required this.latestPeriod,
  });

  final String buyerId;
  final String buyerName;
  final String commodityId;
  final String commodityName;
  final String commodityUnit;
  final String predictionPeriod;
  final double predictedQuantity;
  final int historyCount;
  final double latestQuantity;
  final String latestPeriod;
}
