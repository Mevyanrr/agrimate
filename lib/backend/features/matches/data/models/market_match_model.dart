import '../../domain/entities/market_match.dart';

class MarketMatchModel extends MarketMatch {
  const MarketMatchModel({required super.id, required super.data});

  factory MarketMatchModel.fromJson(Map<String, dynamic> json) {
    return MarketMatchModel(id: json['id'].toString(), data: json);
  }
}
