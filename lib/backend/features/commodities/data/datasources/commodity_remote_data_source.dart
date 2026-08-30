import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/database_tables.dart';
import '../models/commodity_model.dart';

abstract interface class CommodityRemoteDataSource {
  Future<List<CommodityModel>> getActive();
  Future<CommodityPriceModel?> getLatestNationalProducerPrice(
    String commodityId,
  );
}

class SupabaseCommodityRemoteDataSource implements CommodityRemoteDataSource {
  const SupabaseCommodityRemoteDataSource(this._client);

  final SupabaseClient _client;

  @override
  Future<List<CommodityModel>> getActive() async {
    final rows = await _client
        .from(DatabaseTables.commodities)
        .select()
        .eq('is_active', true)
        .order('name');
    return rows.map(CommodityModel.fromJson).toList();
  }

  @override
  Future<CommodityPriceModel?> getLatestNationalProducerPrice(
    String commodityId,
  ) async {
    final row = await _client
        .from(DatabaseTables.commodityPrices)
        .select()
        .eq('commodity_id', commodityId)
        .eq('market_level', 'PRODUCER')
        .eq('region_level', 'NATIONAL')
        .order('source_date', ascending: false)
        .limit(1)
        .maybeSingle();
    return row == null ? null : CommodityPriceModel.fromJson(row);
  }
}
