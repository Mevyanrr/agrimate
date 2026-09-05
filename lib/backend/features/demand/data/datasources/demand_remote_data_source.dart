import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/database_tables.dart';
import '../../../../core/errors/backend_exception.dart';
import '../models/demand_forecast_model.dart';

abstract interface class DemandRemoteDataSource {
  Future<List<DemandForecastModel>> getMine();
  Future<List<DemandForecastModel>> getMarketplace();
  Future<DemandForecastModel> create(DemandForecastModel demand);
  Future<DemandForecastModel> updateMine(DemandForecastModel demand);
}

class SupabaseDemandRemoteDataSource implements DemandRemoteDataSource {
  const SupabaseDemandRemoteDataSource(this._client);
  final SupabaseClient _client;
  String get _userId =>
      _client.auth.currentUser?.id ??
      (throw const BackendException(
        'Pengguna belum login.',
        code: 'unauthenticated',
      ));

  @override
  Future<List<DemandForecastModel>> getMine() async {
    final rows = await _client
        .from(DatabaseTables.demandForecasts)
        .select()
        .eq('buyer_id', _userId)
        .order('needed_start_date');
    return rows.map(DemandForecastModel.fromJson).toList();
  }

  @override
  Future<List<DemandForecastModel>> getMarketplace() async {
    final rows = await _client
        .from(DatabaseTables.demandForecasts)
        .select()
        .order('needed_start_date');
    return rows.map(DemandForecastModel.fromJson).toList();
  }

  @override
  Future<DemandForecastModel> create(DemandForecastModel demand) async {
    final row = await _client
        .from(DatabaseTables.demandForecasts)
        .insert({
          ...demand.toEditableJson(),
          'buyer_id': _userId,
          'commodity_id': demand.commodityId,
          'remaining_quantity': demand.quantity,
        })
        .select()
        .single();
    await _client.rpc(
      'run_demand_matching',
      params: {'p_demand_id': row['id']},
    );
    return DemandForecastModel.fromJson(row);
  }

  @override
  Future<DemandForecastModel> updateMine(DemandForecastModel demand) async {
    final id =
        demand.id ?? (throw const BackendException('Demand ID wajib diisi.'));
    final row = await _client
        .from(DatabaseTables.demandForecasts)
        .update(demand.toEditableJson())
        .eq('id', id)
        .eq('buyer_id', _userId)
        .select()
        .single();
    return DemandForecastModel.fromJson(row);
  }
}
