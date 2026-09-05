import '../../../../core/result/result.dart';
import '../entities/market_match.dart';

abstract interface class MatchRepository {
  Future<Result<List<MarketMatch>>> getMine();
  Future<Result<void>> confirm(String matchId);
  Future<Result<void>> reject(String matchId);
}
