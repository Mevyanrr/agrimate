
import 'package:agrimate/petani_features/hasil_kecocokan_panen/model/matching_buyer_model.dart';
import 'package:agrimate/petani_features/hasil_kecocokan_panen/model/matching_result_model.dart';
import 'package:agrimate/petani_features/hasil_kecocokan_panen/model/rencana_summary_model.dart';

abstract class MatchingRepository {
  Future<MatchingResultModel> searchMatches(RencanaSummaryModel rencana);

  Future<bool> respondToBuyer({required String buyerId, required bool accept});
}

class MatchingRepositoryImpl implements MatchingRepository {
  @override
  Future<MatchingResultModel> searchMatches(RencanaSummaryModel rencana) async {

    await Future.delayed(const Duration(seconds: 5));

    return MatchingResultModel(
      komoditasName: rencana.komoditasName,
      komoditasEmoji: rencana.komoditasEmoji,
      totalKg: rencana.kuantitasKg,
      terjualKg: rencana.kuantitasKg,
      buyers: const [
        MatchingBuyerModel(
          id: 'b1',
          name: 'Restoran Sate Khas',
          type: 'Restoran',
          location: 'Semarang',
          matchPercentage: 98,
          alokasiKg: 33,
          hargaPerKg: 8500,
          estimasiRp: 281000,
        ),
        MatchingBuyerModel(
          id: 'b2',
          name: 'CV Nusantara Distributor',
          type: 'Distributor',
          location: 'Solo',
          matchPercentage: 91,
          alokasiKg: 33,
          hargaPerKg: 8000,
          estimasiRp: 264000,
        ),
        MatchingBuyerModel(
          id: 'b3',
          name: 'Toko Sayur Makmur',
          type: 'Toko Sembako',
          location: 'Yogyakarta',
          matchPercentage: 87,
          alokasiKg: 34,
          hargaPerKg: 9000,
          estimasiRp: 306000,
        ),
      ],
    );
  }

  @override
  Future<bool> respondToBuyer({required String buyerId, required bool accept}) async {

    await Future.delayed(const Duration(milliseconds: 400));
    return true;
  }
}