import '../../../../core/result/result.dart';
import '../entities/market_transaction.dart';

abstract interface class TransactionRepository {
  Future<Result<List<MarketTransaction>>> getMine();
  Future<Result<MarketTransaction?>> getByMatchId(String matchId);
  Future<Result<void>> complete(String transactionId);
  Future<Result<void>> submitRating({
    required String transactionId,
    required int rating,
    String? comment,
  });
}
