import '../../../../core/result/result.dart';
import '../entities/supply_forecast.dart';

abstract interface class SupplyRepository {
  Future<Result<List<SupplyForecast>>> getMine();
  Future<Result<List<SupplyForecast>>> getMarketplace();
  Future<Result<SupplyForecast>> create(SupplyForecast supply);
  Future<Result<SupplyForecast>> updateMine(SupplyForecast supply);
}
