import '../../../../core/result/result.dart';
import '../../domain/entities/commodity.dart';
import '../../domain/repositories/commodity_repository.dart';
import '../datasources/commodity_remote_data_source.dart';

class CommodityRepositoryImpl implements CommodityRepository {
  const CommodityRepositoryImpl(this._source);
  final CommodityRemoteDataSource _source;

  @override
  Future<Result<List<Commodity>>> getCommodities() async {
    try {
      return Success<List<Commodity>>(await _source.getCommodities());
    } catch (error) {
      return Failure<List<Commodity>>('Gagal mengambil komoditas: $error');
    }
  }
}
