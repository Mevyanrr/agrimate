import '../../../../core/result/result.dart';
import '../entities/app_notification.dart';

abstract interface class NotificationRepository {
  Future<Result<List<AppNotification>>> getMine();
  Future<Result<void>> markAsRead(String notificationId);
  Future<Result<void>> markAllAsRead();
  Future<Result<int>> getUnreadCount();
}
