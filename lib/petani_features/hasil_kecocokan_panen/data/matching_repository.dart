import 'package:agrimate/backend/backend_dependencies.dart';
import 'package:agrimate/backend/core/result/result.dart';
import 'package:agrimate/backend/features/matches/domain/entities/market_match.dart';
import 'package:agrimate/petani_features/hasil_kecocokan_panen/model/matching_buyer_model.dart';
import 'package:agrimate/petani_features/hasil_kecocokan_panen/model/matching_result_model.dart';
import 'package:agrimate/petani_features/hasil_kecocokan_panen/model/rencana_summary_model.dart';

abstract class MatchingRepository {
  Future<MatchingResultModel> searchMatches(RencanaSummaryModel rencana);

  Future<bool> respondToBuyer({required String buyerId, required bool accept});
}

class MatchingRepositoryImpl implements MatchingRepository {
  MatchingRepositoryImpl({BackendDependencies? backend})
    : _backend = backend ?? BackendDependencies.create();

  final BackendDependencies _backend;

  @override
  Future<MatchingResultModel> searchMatches(RencanaSummaryModel rencana) async {
    final result = await _backend.matches.getMine();
    if (result case Failure(message: final message)) {
      throw StateError(message);
    }

    final matches = (result as Success<List<MarketMatch>>).data
      .where((match) => _belongsToPlan(match.data, rencana))
      .where((match) => !_isSelfMatch(match.data))
        .map(_toBuyer)
        .toList();
    final allocated = matches.fold<int>(
      0,
      (total, match) => total + match.alokasiKg,
    );
    return MatchingResultModel(
      komoditasName: rencana.komoditasName,
      komoditasEmoji: rencana.komoditasEmoji,
      totalKg: rencana.kuantitasKg,
      terjualKg: allocated.clamp(0, rencana.kuantitasKg),
      buyers: matches,
    );
  }

  @override
  Future<bool> respondToBuyer({
    required String buyerId,
    required bool accept,
  }) async {
    final result = accept
        ? await _backend.matches.confirm(buyerId)
        : await _backend.matches.reject(buyerId);
    return result is Success<void>;
  }

  bool _belongsToPlan(Map<String, dynamic> data, RencanaSummaryModel rencana) {
    final supply = _map(data['supply']);
    final demand = _map(data['demand']);
    final commodity = _map(supply['commodity']);
    final name = commodity['name']?.toString().trim().toLowerCase();
    if (name != rencana.komoditasName.trim().toLowerCase()) return false;

    final start = _date(
      supply['harvest_start_date'] ?? demand['needed_start_date'],
    );
    final end = _date(supply['harvest_end_date'] ?? demand['needed_end_date']);
    if (start == null || end == null) return true;
    return !end.isBefore(rencana.tanggalMulai) &&
        !start.isAfter(rencana.tanggalSelesai);
  }

  bool _isSelfMatch(Map<String, dynamic> data) {
    final supply = _map(data['supply']);
    final demand = _map(data['demand']);
    final farmerId = supply['farmer_id']?.toString();
    final buyerId = demand['buyer_id']?.toString();
    return farmerId != null && farmerId == buyerId;
  }

  MatchingBuyerModel _toBuyer(MarketMatch match) {
    final data = match.data;
    final supply = _map(data['supply']);
    final demand = _map(data['demand']);
    final quantity = _number(data['matched_quantity']).round();
    final price = _number(data['reference_price']).round();
    final status = data['status']?.toString().toUpperCase();
    final buyerProfile = _map(data['_buyer_profile']);
    final farmerProfile = _map(data['_farmer_profile']);
    final profile = buyerProfile.isNotEmpty ? buyerProfile : farmerProfile;
    final realName = profile['full_name']?.toString().trim();
    final businessName = profile['business_name']?.toString().trim();
    return MatchingBuyerModel(
      id: match.id,
      name: realName == null || realName.isEmpty
          ? 'Profil tidak tersedia'
          : realName,
      type: businessName == null || businessName.isEmpty
          ? 'Jenis usaha tidak tersedia'
          : businessName,
      location:
          demand['delivery_address']?.toString() ??
          supply['address']?.toString() ??
          data['province']?.toString() ??
          '-',
      matchPercentage: 100,
      alokasiKg: quantity,
      hargaPerKg: price,
      estimasiRp: quantity * price,
      status: status == 'CONFIRMED'
          ? BuyerResponseStatus.accepted
          : status == 'REJECTED'
          ? BuyerResponseStatus.rejected
          : BuyerResponseStatus.pending,
    );
  }
}

Map<String, dynamic> _map(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : const <String, dynamic>{};

num _number(Object? value) =>
    value is num ? value : num.tryParse('$value') ?? 0;

DateTime? _date(Object? value) => DateTime.tryParse(value?.toString() ?? '');
