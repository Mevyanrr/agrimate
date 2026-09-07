import 'package:agrimate/backend/backend_dependencies.dart';
import 'package:agrimate/backend/core/result/result.dart';
import 'package:agrimate/backend/features/supply/domain/entities/supply_forecast.dart';
import 'package:agrimate/backend/features/demand/domain/entities/demand_forecast.dart';
import 'package:agrimate/role_selection/model/role.dart';

abstract class RencanaRepository {
  Future<bool> saveDraft(Map<String, dynamic> data);

  Future<bool> submitRencana(Map<String, dynamic> data, UserRole role);
}

class RencanaRepositoryImpl implements RencanaRepository {
  RencanaRepositoryImpl() : _backend = BackendDependencies.create();

  final BackendDependencies _backend;

  @override
  Future<bool> saveDraft(Map<String, dynamic> data) async {
    return true;
  }

  @override
  Future<bool> submitRencana(Map<String, dynamic> data, UserRole role) async {
    final start = DateTime.tryParse(data['tanggal_mulai']?.toString() ?? '');
    final end = DateTime.tryParse(data['tanggal_selesai']?.toString() ?? '');
    final commodityId = data['komoditas_id']?.toString();
    if (start == null || end == null || commodityId == null) {
      throw StateError('Data forecast belum lengkap.');
    }

    if (role == UserRole.petani) {
      final result = await _backend.supplyRepository.create(
        SupplyForecast(
          commodityId: commodityId,
          quantity: (data['kuantitas_kg'] as num?) ?? 0,
          harvestStartDate: start,
          harvestEndDate: end,
          address: '',
        ),
      );
      if (result case Failure(message: final message)) {
        throw StateError(message);
      }
      return result is Success<SupplyForecast>;
    }

    final result = await _backend.demandRepository.create(
      DemandForecast(
        commodityId: commodityId,
        quantity: (data['kuantitas_kg'] as num?) ?? 0,
        neededStartDate: start,
        neededEndDate: end,
        deliveryAddress: '',
        forecastSource: 'MANUAL',
      ),
    );
    if (result case Failure(message: final message)) {
      throw StateError(message);
    }
    return result is Success<DemandForecast>;
  }
}
