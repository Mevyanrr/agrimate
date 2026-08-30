import '../../../../core/result/result.dart';
import '../../domain/entities/demand_forecast.dart';
import '../../domain/repositories/demand_repository.dart';
import '../datasources/demand_remote_data_source.dart';
import '../models/demand_forecast_model.dart';

class DemandRepositoryImpl implements DemandRepository {
  const DemandRepositoryImpl(this._source);
  final DemandRemoteDataSource _source;

  DemandForecastModel _model(DemandForecast value) => DemandForecastModel(
    id: value.id, buyerId: value.buyerId, commodityId: value.commodityId,
    quantity: value.quantity, remainingQuantity: value.remainingQuantity,
    neededStartDate: value.neededStartDate, neededEndDate: value.neededEndDate,
    deliveryAddress: value.deliveryAddress, status: value.status,
  );

  Future<Result<List<DemandForecast>>> _list(
    Future<List<DemandForecastModel>> Function() load,
  ) async {
    try { return Success<List<DemandForecast>>(await load()); }
    catch (error) { return Failure<List<DemandForecast>>('$error'); }
  }

  @override
  Future<Result<List<DemandForecast>>> getMine() => _list(_source.getMine);
  @override
  Future<Result<List<DemandForecast>>> getMarketplace() => _list(_source.getMarketplace);
  @override
  Future<Result<DemandForecast>> create(DemandForecast demand) async {
    try { return Success<DemandForecast>(await _source.create(_model(demand))); }
    catch (error) { return Failure<DemandForecast>('$error'); }
  }
  @override
  Future<Result<DemandForecast>> updateMine(DemandForecast demand) async {
    try { return Success<DemandForecast>(await _source.updateMine(_model(demand))); }
    catch (error) { return Failure<DemandForecast>('$error'); }
  }
}
