import '../../domain/entities/demand_prediction.dart';

class DemandPredictionModel extends DemandPrediction {
  const DemandPredictionModel({
    required super.buyerId,
    required super.buyerName,
    required super.commodityId,
    required super.commodityName,
    required super.commodityUnit,
    required super.predictionPeriod,
    required super.predictedQuantity,
    required super.historyCount,
    required super.latestQuantity,
    required super.latestPeriod,
  });

  factory DemandPredictionModel.fromJson(Map<String, dynamic> json) {
    final buyer = Map<String, dynamic>.from(json['buyer'] as Map);
    final commodity = Map<String, dynamic>.from(json['commodity'] as Map);
    final prediction = Map<String, dynamic>.from(json['prediction'] as Map);
    final history = Map<String, dynamic>.from(json['history'] as Map);
    return DemandPredictionModel(
      buyerId: buyer['id'].toString(),
      buyerName: buyer['name'] as String,
      commodityId: commodity['id'].toString(),
      commodityName: commodity['name'] as String,
      commodityUnit: commodity['unit'] as String,
      predictionPeriod: prediction['period_start'] as String,
      predictedQuantity: (prediction['predicted_quantity'] as num).toDouble(),
      historyCount: (history['count'] as num).toInt(),
      latestQuantity: (history['latest_quantity'] as num).toDouble(),
      latestPeriod: history['latest_period'] as String,
    );
  }
}
