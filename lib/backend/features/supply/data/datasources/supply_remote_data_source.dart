import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/database_tables.dart';
import '../../../../core/errors/backend_exception.dart';
import '../models/supply_forecast_model.dart';

abstract interface class SupplyRemoteDataSource {
  Future<List<SupplyForecastModel>> getMine();
  Future<List<SupplyForecastModel>> getMarketplace();
  Future<SupplyForecastModel> create(SupplyForecastModel supply);
  Future<SupplyForecastModel> updateMine(SupplyForecastModel supply);
}

class SupabaseSupplyRemoteDataSource implements SupplyRemoteDataSource {
  const SupabaseSupplyRemoteDataSource(this._client);
  final SupabaseClient _client;

  String get _userId => _client.auth.currentUser?.id ??
      (throw const BackendException('Pengguna belum login.', code: 'unauthenticated'));

  @override
  Future<List<SupplyForecastModel>> getMine() async {
    final rows = await _client.from(DatabaseTables.supplyForecasts).select()
        .eq('farmer_id', _userId).order('harvest_start_date');
    return rows.map(SupplyForecastModel.fromJson).toList();
  }

  @override
  Future<List<SupplyForecastModel>> getMarketplace() async {
    final rows = await _client.from(DatabaseTables.supplyForecasts).select()
        .order('harvest_start_date');
    return rows.map(SupplyForecastModel.fromJson).toList();
  }

  @override
  Future<SupplyForecastModel> create(SupplyForecastModel supply) async {
    final row = await _client.from(DatabaseTables.supplyForecasts).insert({
      ...supply.toEditableJson(),
      'farmer_id': _userId,
      'commodity_id': supply.commodityId,
      'remaining_quantity': supply.quantity,
    }).select().single();
    await _client.rpc('run_supply_matching', params: {'p_supply_id': row['id']});
    return SupplyForecastModel.fromJson(row);
  }

  @override
  Future<SupplyForecastModel> updateMine(SupplyForecastModel supply) async {
    final id = supply.id ?? (throw const BackendException('Supply ID wajib diisi.'));
    final row = await _client.from(DatabaseTables.supplyForecasts)
        .update(supply.toEditableJson()).eq('id', id).eq('farmer_id', _userId)
        .select().single();
    return SupplyForecastModel.fromJson(row);
  }
}
