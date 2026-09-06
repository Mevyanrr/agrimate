import 'package:agrimate/backend/backend_dependencies.dart';
import 'package:agrimate/backend/core/result/result.dart';
import 'package:agrimate/backend/features/supply/domain/entities/supply_forecast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class RencanaRepository {
  Future<bool> saveDraft(Map<String, dynamic> data);

  Future<bool> submitRencana(Map<String, dynamic> data);
}

class RencanaRepositoryImpl implements RencanaRepository {
  RencanaRepositoryImpl() : _backend = BackendDependencies.create();

  final BackendDependencies _backend;

  @override
  Future<bool> saveDraft(Map<String, dynamic> data) async {
    return true;
  }

  @override
  Future<bool> submitRencana(Map<String, dynamic> data) async {
    final start = DateTime.tryParse(data['tanggal_mulai']?.toString() ?? '');
    final end = DateTime.tryParse(data['tanggal_selesai']?.toString() ?? '');
    final commodityId = data['komoditas_id']?.toString();
    if (start == null || end == null || commodityId == null) {
      throw StateError('Data rencana panen belum lengkap.');
    }

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) throw StateError('Sesi login tidak ditemukan.');
    final details = await Supabase.instance.client
        .from('farmer_details')
        .select('land_address')
        .eq('user_id', userId)
        .maybeSingle();
    final address = details?['land_address']?.toString().trim();
    if (address == null || address.isEmpty) {
      throw StateError('Alamat lahan belum tersimpan di profil.');
    }

    final result = await _backend.supplyRepository.create(
      SupplyForecast(
        commodityId: commodityId,
        quantity: (data['kuantitas_kg'] as num?) ?? 0,
        harvestStartDate: start,
        harvestEndDate: end,
        address: address,
      ),
    );
    if (result case Failure(message: final message)) {
      throw StateError(message);
    }
    return result is Success<SupplyForecast>;
  }
}
