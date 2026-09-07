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

  String get _userId =>
      _client.auth.currentUser?.id ??
      (throw const BackendException(
        'Pengguna belum login.',
        code: 'unauthenticated',
      ));

  @override
  Future<List<SupplyForecastModel>> getMine() async {
    final rows = await _client
        .from(DatabaseTables.supplyForecasts)
        .select()
        .eq('farmer_id', _userId)
        .order('harvest_start_date');
    return rows.map(SupplyForecastModel.fromJson).toList();
  }

  @override
  Future<List<SupplyForecastModel>> getMarketplace() async {
    final rows = await _client
        .from(DatabaseTables.supplyForecasts)
        .select()
        .order('harvest_start_date');
    final enriched = rows.map((row) => Map<String, dynamic>.from(row)).toList();
    final ids = enriched
        .map((row) => row['farmer_id']?.toString())
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
          row['_farmer_name'] = names[row['farmer_id']?.toString()];
        }
      } catch (_) {
        // Forecast tetap ditampilkan tanpa membuat nama pengganti palsu.
      }
    }
    return enriched.map(SupplyForecastModel.fromJson).toList();
  }

  @override
  Future<SupplyForecastModel> create(SupplyForecastModel supply) async {
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
        .from(DatabaseTables.supplyForecasts)
        .insert({
          ...supply.toEditableJson(),
          'farmer_id': _userId,
          'commodity_id': supply.commodityId,
          'remaining_quantity': supply.quantity,
          'address': profile['address'] ?? supply.address,
          'province': province,
          'city': profile['city'],
          'district': profile['district'],
          'latitude': profile['latitude'],
          'longitude': profile['longitude'],
        })
        .select()
        .single();
    await _client.rpc(
      'run_supply_matching',
      params: {'p_supply_id': row['id']},
    );
    return SupplyForecastModel.fromJson(row);
  }

  @override
  Future<SupplyForecastModel> updateMine(SupplyForecastModel supply) async {
    final id =
        supply.id ?? (throw const BackendException('Supply ID wajib diisi.'));
    final row = await _client
        .from(DatabaseTables.supplyForecasts)
        .update(supply.toEditableJson())
        .eq('id', id)
        .eq('farmer_id', _userId)
        .select()
        .single();
    return SupplyForecastModel.fromJson(row);
  }
}
