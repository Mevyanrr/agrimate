import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/database_tables.dart';
import '../models/market_match_model.dart';

abstract interface class MatchRemoteDataSource {
  Future<List<MarketMatchModel>> getMine();
  Future<void> confirm(String matchId);
  Future<void> reject(String matchId);
}

class SupabaseMatchRemoteDataSource implements MatchRemoteDataSource {
  const SupabaseMatchRemoteDataSource(this._client);
  final SupabaseClient _client;

  @override
  Future<List<MarketMatchModel>> getMine() async {
    // RLS wajib membatasi hasil ke match milik user yang sedang login.
    final rows = await _client.from(DatabaseTables.matches).select();
    return rows.map(MarketMatchModel.fromJson).toList();
  }

  @override
  Future<void> confirm(String matchId) =>
      _client.rpc('confirm_match', params: {'p_match_id': matchId});

  @override
  Future<void> reject(String matchId) =>
      _client.rpc('reject_match', params: {'p_match_id': matchId});
}
