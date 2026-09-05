import '../../../../core/result/result.dart';
import '../../domain/entities/supply_forecast.dart';
import '../../domain/repositories/supply_repository.dart';
import '../datasources/supply_remote_data_source.dart';
import '../models/supply_forecast_model.dart';

class SupplyRepositoryImpl implements SupplyRepository {
  const SupplyRepositoryImpl(this._source);
  final SupplyRemoteDataSource _source;

  SupplyForecastModel _model(SupplyForecast value) => SupplyForecastModel(
    id: value.id, farmerId: value.farmerId, commodityId: value.commodityId,
    quantity: value.quantity, remainingQuantity: value.remainingQuantity,
    harvestStartDate: value.harvestStartDate,
    harvestEndDate: value.harvestEndDate, address: value.address,
    latitude: value.latitude, longitude: value.longitude,
    status: value.status,
  );

  Future<Result<List<SupplyForecast>>> _list(
    Future<List<SupplyForecastModel>> Function() load,
  ) async {
    try { return Success<List<SupplyForecast>>(await load()); }
    catch (error) { return Failure<List<SupplyForecast>>('$error'); }
  }

  @override
  Future<Result<List<SupplyForecast>>> getMine() => _list(_source.getMine);
  @override
  Future<Result<List<SupplyForecast>>> getMarketplace() => _list(_source.getMarketplace);
  @override
  Future<Result<SupplyForecast>> create(SupplyForecast supply) async {
    try { return Success<SupplyForecast>(await _source.create(_model(supply))); }
    catch (error) { return Failure<SupplyForecast>('$error'); }
  }
  @override
  Future<Result<SupplyForecast>> updateMine(SupplyForecast supply) async {
    try { return Success<SupplyForecast>(await _source.updateMine(_model(supply))); }
    catch (error) { return Failure<SupplyForecast>('$error'); }
  }
}
