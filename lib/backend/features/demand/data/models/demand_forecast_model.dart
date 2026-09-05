import '../../domain/entities/demand_forecast.dart';

class DemandForecastModel extends DemandForecast {
  const DemandForecastModel({
    super.id,
    super.buyerId,
    required super.commodityId,
    required super.quantity,
    super.remainingQuantity,
    required super.neededStartDate,
    required super.neededEndDate,
    required super.deliveryAddress,
    super.status,
    super.latitude,
    super.longitude,
    super.forecastSource,
  });

  factory DemandForecastModel.fromJson(Map<String, dynamic> json) =>
      DemandForecastModel(
        id: json['id'].toString(),
        buyerId: json['buyer_id'].toString(),
        commodityId: json['commodity_id'].toString(),
        quantity: json['quantity'] as num,
        remainingQuantity: json['remaining_quantity'] as num?,
        neededStartDate: DateTime.parse(json['needed_start_date'] as String),
        neededEndDate: DateTime.parse(json['needed_end_date'] as String),
        deliveryAddress: json['delivery_address'] as String,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        forecastSource: json['forecast_source'] as String? ?? 'MANUAL',
        status: json['status'] as String?,
      );

  Map<String, dynamic> toEditableJson() => {
    'quantity': quantity,
    'needed_start_date': neededStartDate.toIso8601String().split('T').first,
    'needed_end_date': neededEndDate.toIso8601String().split('T').first,
    'delivery_address': deliveryAddress,
    'latitude': latitude,
    'longitude': longitude,
    'forecast_source': forecastSource,
  };
}
