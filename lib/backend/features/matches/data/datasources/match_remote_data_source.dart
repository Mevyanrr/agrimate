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
    final rows = await _client
        .from(DatabaseTables.matches)
        .select('''
      *,
      supply:supply_id (
        *,
        commodity:commodity_id (*)
      ),
      demand:demand_id (*)
    ''')
        .order('created_at', ascending: false);
    final enriched = rows.map((row) => Map<String, dynamic>.from(row)).toList();
    final userIds = <String>{};
    for (final row in enriched) {
      final supply = row['supply'];
      final demand = row['demand'];
      if (supply is Map && supply['farmer_id'] != null) {
        userIds.add(supply['farmer_id'].toString());
      }
      if (demand is Map && demand['buyer_id'] != null) {
        userIds.add(demand['buyer_id'].toString());
      }
    }
    if (userIds.isNotEmpty) {
      try {
        final profiles = await _client
            .from(DatabaseTables.profiles)
            .select('id, full_name, business_name')
            .inFilter('id', userIds.toList());
        final profileById = {
          for (final profile in profiles) profile['id'].toString(): profile,
        };
        for (final row in enriched) {
          final supply = row['supply'];
          final demand = row['demand'];
          if (supply is Map) {
            row['_farmer_profile'] =
                profileById[supply['farmer_id']?.toString()];
          }
          if (demand is Map) {
            row['_buyer_profile'] = profileById[demand['buyer_id']?.toString()];
          }
        }
      } catch (_) {
        // Match tetap valid; UI tidak mengarang identitas jika profil tak terbaca.
      }
    }
    for (final row in enriched) {
      final currentPrice =
          num.tryParse(row['reference_price']?.toString() ?? '') ?? 0;
      if (currentPrice > 0) continue;
      final supply = row['supply'];
      if (supply is! Map || supply['commodity_id'] == null) continue;
      try {
        final prices = await _client.rpc(
          'get_reference_price',
          params: {
            'p_commodity_id': supply['commodity_id'],
            'p_province': row['province'] ?? supply['province'],
          },
        );
        if (prices is List && prices.isNotEmpty && prices.first is Map) {
          final price = Map<String, dynamic>.from(prices.first as Map);
          row['reference_price'] = price['price'];
          row['price_source'] = price['source'];
          row['price_source_date'] = price['source_date'];
        }
      } catch (_) {
        // Match lama tanpa snapshot tetap ditampilkan, tanpa harga buatan.
      }
    }
    return enriched.map(MarketMatchModel.fromJson).toList();
  }

  @override
  Future<void> confirm(String matchId) =>
      _client.rpc('confirm_match', params: {'p_match_id': matchId});

  @override
  Future<void> reject(String matchId) =>
      _client.rpc('reject_match', params: {'p_match_id': matchId});
}
