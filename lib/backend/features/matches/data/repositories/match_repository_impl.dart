import '../../../../core/result/result.dart';
import '../../domain/entities/market_match.dart';
import '../../domain/repositories/match_repository.dart';
import '../datasources/match_remote_data_source.dart';

class MatchRepositoryImpl implements MatchRepository {
  const MatchRepositoryImpl(this._source);

  final MatchRemoteDataSource _source;

  @override
  Future<Result<List<MarketMatch>>> getMine() async {
    try {
      return Success<List<MarketMatch>>(await _source.getMine());
    } catch (error) {
      return Failure<List<MarketMatch>>('$error');
    }
  }

  @override
  Future<Result<void>> confirm(String matchId) async {
    try {
      await _source.confirm(matchId);
      return const Success<void>(null);
    } catch (error) {
      return Failure<void>('$error');
    }
  }

  @override
  Future<Result<void>> reject(String matchId) async {
    try {
      await _source.reject(matchId);
      return const Success<void>(null);
    } catch (error) {
      return Failure<void>('$error');
    }
  }
}
