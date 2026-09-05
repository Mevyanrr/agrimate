import '../../../../core/result/result.dart';
import '../../domain/entities/market_transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_remote_data_source.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  const TransactionRepositoryImpl(this._source);

  final TransactionRemoteDataSource _source;

  @override
  Future<Result<List<MarketTransaction>>> getMine() async {
    try {
      return Success<List<MarketTransaction>>(await _source.getMine());
    } catch (error) {
      return Failure<List<MarketTransaction>>('$error');
    }
  }

  @override
  Future<Result<MarketTransaction?>> getByMatchId(String matchId) async {
    try {
      return Success<MarketTransaction?>(await _source.getByMatchId(matchId));
    } catch (error) {
      return Failure<MarketTransaction?>('$error');
    }
  }
}
