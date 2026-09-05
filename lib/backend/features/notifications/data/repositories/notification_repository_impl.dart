import '../../../../core/result/result.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  const NotificationRepositoryImpl(this._source);

  final NotificationRemoteDataSource _source;

  @override
  Future<Result<List<AppNotification>>> getMine() async {
    try {
      return Success<List<AppNotification>>(await _source.getMine());
    } catch (error) {
      return Failure<List<AppNotification>>(
        'Gagal mengambil notifikasi: $error',
      );
    }
  }

  @override
  Future<Result<void>> markAsRead(String notificationId) async {
    try {
      await _source.markAsRead(notificationId);
      return const Success<void>(null);
    } catch (error) {
      return Failure<void>('Gagal menandai notifikasi: $error');
    }
  }

  @override
  Future<Result<void>> markAllAsRead() async {
    try {
      await _source.markAllAsRead();
      return const Success<void>(null);
    } catch (error) {
      return Failure<void>('Gagal menandai semua notifikasi: $error');
    }
  }

  @override
  Future<Result<int>> getUnreadCount() async {
    try {
      return Success<int>(await _source.getUnreadCount());
    } catch (error) {
      return Failure<int>('Gagal mengambil jumlah notifikasi: $error');
    }
  }
}
