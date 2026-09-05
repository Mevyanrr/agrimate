import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/database_tables.dart';
import '../models/commodity_model.dart';

abstract interface class CommodityRemoteDataSource {
  Future<List<CommodityModel>> getCommodities();
}

class SupabaseCommodityRemoteDataSource implements CommodityRemoteDataSource {
  const SupabaseCommodityRemoteDataSource(this._client);

  final SupabaseClient _client;

  @override
  Future<List<CommodityModel>> getCommodities() async {
    final rows = await _client
        .from(DatabaseTables.commodityLatestPrices)
        .select()
        .order('name');
    return rows.map(CommodityModel.fromJson).toList();
  }
}
