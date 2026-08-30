import '../../../../core/result/result.dart';
import '../entities/demand_forecast.dart';

abstract interface class DemandRepository {
  Future<Result<List<DemandForecast>>> getMine();
  Future<Result<List<DemandForecast>>> getMarketplace();
  Future<Result<DemandForecast>> create(DemandForecast demand);
  Future<Result<DemandForecast>> updateMine(DemandForecast demand);
}
