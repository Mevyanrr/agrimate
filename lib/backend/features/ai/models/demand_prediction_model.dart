class DemandPredictionModel {
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

  DemandPredictionModel({
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

  factory DemandPredictionModel.fromJson(Map<String, dynamic> json) {
    return DemandPredictionModel(
      buyerId: json['buyer']['id'],
      buyerName: json['buyer']['name'],

      commodityId: json['commodity']['id'],
      commodityName: json['commodity']['name'],
      commodityUnit: json['commodity']['unit'],

      predictionPeriod: json['prediction']['period_start'],

      predictedQuantity: (json['prediction']['predicted_quantity'] as num)
          .toDouble(),

      historyCount: json['history']['count'],

      latestQuantity: (json['history']['latest_quantity'] as num).toDouble(),

      latestPeriod: json['history']['latest_period'],
    );
  }
}
