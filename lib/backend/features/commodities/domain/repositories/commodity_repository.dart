import '../../../../core/result/result.dart';
import '../entities/commodity.dart';

abstract interface class CommodityRepository {
  Future<Result<List<Commodity>>> getActive();
  Future<Result<CommodityPrice?>> getLatestNationalProducerPrice(String id);
}
