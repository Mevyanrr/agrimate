import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/database_tables.dart';
import '../models/market_transaction_model.dart';

abstract interface class TransactionRemoteDataSource {
  Future<List<MarketTransactionModel>> getMine();
  Future<MarketTransactionModel?> getByMatchId(String matchId);
}

class SupabaseTransactionRemoteDataSource implements TransactionRemoteDataSource {
  const SupabaseTransactionRemoteDataSource(this._client);
  final SupabaseClient _client;

  @override
  Future<List<MarketTransactionModel>> getMine() async {
    // Tidak ada insert/update/delete: transaction dikelola backend.
    final rows = await _client.from(DatabaseTables.transactions).select('''
      *,
      commodity:commodity_id (*)
    ''')
        .order('created_at', ascending: false);
    return rows.map(MarketTransactionModel.fromJson).toList();
  }

  @override
  Future<MarketTransactionModel?> getByMatchId(String matchId) async {
    final row = await _client.from(DatabaseTables.transactions).select('''
      *,
      commodity:commodity_id (*)
    ''').eq('match_id', matchId).maybeSingle();
    return row == null ? null : MarketTransactionModel.fromJson(row);
  }
}
