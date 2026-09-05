import '../../../../core/result/result.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_data_source.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl(this._source);
  final DashboardRemoteDataSource _source;

  @override
  Future<Result<DashboardSummary>> getSummary() async {
    try {
      return Success(await _source.getSummary());
    } catch (error) {
      return Failure<DashboardSummary>('Gagal mengambil dashboard: $error');
    }
  }
}
