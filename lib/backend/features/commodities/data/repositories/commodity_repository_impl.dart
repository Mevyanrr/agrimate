import '../../../../core/result/result.dart';
import '../../domain/entities/commodity.dart';
import '../../domain/repositories/commodity_repository.dart';
import '../datasources/commodity_remote_data_source.dart';

class CommodityRepositoryImpl implements CommodityRepository {
  const CommodityRepositoryImpl(this._source);
  final CommodityRemoteDataSource _source;

  @override
  Future<Result<List<Commodity>>> getActive() async {
    try {
      return Success<List<Commodity>>(await _source.getActive());
    } catch (error) {
      return Failure<List<Commodity>>('Gagal mengambil komoditas: $error');
    }
  }

  @override
  Future<Result<CommodityPrice?>> getLatestNationalProducerPrice(String id) async {
    try {
      return Success<CommodityPrice?>(
        await _source.getLatestNationalProducerPrice(id),
      );
    } catch (error) {
      return Failure<CommodityPrice?>('Gagal mengambil harga komoditas: $error');
    }
  }
}
