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
    final enriched = rows.map((row) => Map<String, dynamic>.from(row)).toList();
    final ids = enriched
        .map((row) => row['buyer_id']?.toString())
        .whereType<String>()
        .toSet()
        .toList();
    if (ids.isNotEmpty) {
      try {
        final profiles = await _client
            .from(DatabaseTables.profiles)
            .select('id, full_name')
            .inFilter('id', ids);
        final names = {
          for (final profile in profiles)
            profile['id'].toString(): profile['full_name']?.toString(),
        };
        for (final row in enriched) {
          row['_buyer_name'] = names[row['buyer_id']?.toString()];
        }
      } catch (_) {
        // Forecast tetap ditampilkan tanpa membuat nama pengganti palsu.
      }
    }
    return enriched.map(DemandForecastModel.fromJson).toList();
  }

  @override
  Future<DemandForecastModel> create(DemandForecastModel demand) async {
    final profile = await _client
        .from(DatabaseTables.profiles)
        .select('address, province, city, district, latitude, longitude')
        .eq('id', _userId)
        .single();
    final province = profile['province']?.toString().trim();
    if (province == null || province.isEmpty) {
      throw const BackendException(
        'Provinsi profil belum terverifikasi.',
        code: 'province_required',
      );
    }
    final row = await _client
        .from(DatabaseTables.demandForecasts)
        .insert({
          ...demand.toEditableJson(),
          'buyer_id': _userId,
          'commodity_id': demand.commodityId,
          'remaining_quantity': demand.quantity,
          'delivery_address': profile['address'] ?? demand.deliveryAddress,
          'province': province,
          'city': profile['city'],
          'district': profile['district'],
          'latitude': profile['latitude'],
          'longitude': profile['longitude'],
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
