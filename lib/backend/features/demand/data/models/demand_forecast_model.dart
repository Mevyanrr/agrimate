import '../../domain/entities/demand_forecast.dart';

class DemandForecastModel extends DemandForecast {
  const DemandForecastModel({
    super.id, super.buyerId, required super.commodityId,
    required super.quantity, super.remainingQuantity,
    required super.neededStartDate, required super.neededEndDate,
    required super.deliveryAddress, super.status,
  });

  factory DemandForecastModel.fromJson(Map<String, dynamic> json) => DemandForecastModel(
    id: json['id'].toString(),
    buyerId: json['buyer_id'].toString(),
    commodityId: json['commodity_id'].toString(),
    quantity: json['quantity'] as num,
    remainingQuantity: json['remaining_quantity'] as num?,
    neededStartDate: DateTime.parse(json['needed_start_date'] as String),
    neededEndDate: DateTime.parse(json['needed_end_date'] as String),
    deliveryAddress: json['delivery_address'] as String,
    status: json['status'] as String?,
  );

  Map<String, dynamic> toEditableJson() => {
    'quantity': quantity,
    'needed_start_date': neededStartDate.toIso8601String(),
    'needed_end_date': neededEndDate.toIso8601String(),
    'delivery_address': deliveryAddress,
  };
}
