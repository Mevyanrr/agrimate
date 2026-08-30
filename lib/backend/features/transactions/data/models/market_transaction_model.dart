import '../../domain/entities/market_transaction.dart';

class MarketTransactionModel extends MarketTransaction {
  const MarketTransactionModel({required super.id, required super.data});
  factory MarketTransactionModel.fromJson(Map<String, dynamic> json) =>
      MarketTransactionModel(id: json['id'].toString(), data: json);
}
