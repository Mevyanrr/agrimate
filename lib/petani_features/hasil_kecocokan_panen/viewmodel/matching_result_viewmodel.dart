import 'package:agrimate/petani_features/hasil_kecocokan_panen/data/matching_repository.dart';
import 'package:agrimate/petani_features/hasil_kecocokan_panen/model/matching_buyer_model.dart';
import 'package:agrimate/petani_features/hasil_kecocokan_panen/model/matching_result_model.dart';
import 'package:flutter/foundation.dart';

class MatchingResultViewModel extends ChangeNotifier {
  MatchingResultViewModel({required MatchingResultModel result, MatchingRepository? repository})
      : _repository = repository ?? MatchingRepositoryImpl(),
        _result = result;

  final MatchingRepository _repository;
  MatchingResultModel _result;
  MatchingResultModel get result => _result;

  final Set<String> _loadingBuyerIds = {};
  bool isBuyerLoading(String id) => _loadingBuyerIds.contains(id);

  Future<void> respond(String buyerId, bool accept) async {
    _loadingBuyerIds.add(buyerId);
    notifyListeners();

    final success = await _repository.respondToBuyer(buyerId: buyerId, accept: accept);

    _loadingBuyerIds.remove(buyerId);
    if (success) {
      final updatedBuyers = _result.buyers.map((b) {
        if (b.id == buyerId) {
          return b.copyWith(status: accept ? BuyerResponseStatus.accepted : BuyerResponseStatus.rejected);
        }
        return b;
      }).toList();
      _result = _result.copyWith(buyers: updatedBuyers);
    }
    notifyListeners();
  }
}