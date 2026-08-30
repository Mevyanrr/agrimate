import '../../domain/entities/supply_forecast.dart';

class SupplyForecastModel extends SupplyForecast {
  const SupplyForecastModel({
    super.id,
    super.farmerId,
    required super.commodityId,
    required super.quantity,
    super.remainingQuantity,
    required super.harvestStartDate,
    required super.harvestEndDate,
    required super.address,
    super.status,
  });

  factory SupplyForecastModel.fromJson(Map<String, dynamic> json) {
    return SupplyForecastModel(
      id: json['id'].toString(),
      farmerId: json['farmer_id'].toString(),
      commodityId: json['commodity_id'].toString(),
      quantity: json['quantity'] as num,
      remainingQuantity: json['remaining_quantity'] as num?,
      harvestStartDate: DateTime.parse(json['harvest_start_date'] as String),
      harvestEndDate: DateTime.parse(json['harvest_end_date'] as String),
      address: json['address'] as String,
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toEditableJson() => {
    'quantity': quantity,
    'harvest_start_date': harvestStartDate.toIso8601String(),
    'harvest_end_date': harvestEndDate.toIso8601String(),
    'address': address,
  };
}
