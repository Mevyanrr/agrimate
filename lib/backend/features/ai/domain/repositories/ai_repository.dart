import '../../../../core/result/result.dart';
import '../entities/demand_prediction.dart';

abstract interface class AiRepository {
  Future<Result<DemandPrediction>> predictDemand({required String commodityId});
}
