import '../../domain/entities/app_notification.dart';

class AppNotificationModel extends AppNotification {
  const AppNotificationModel({
    required super.id,
    required super.isRead,
    required super.data,
  });
  factory AppNotificationModel.fromJson(Map<String, dynamic> json) =>
      AppNotificationModel(
        id: json['id'].toString(),
        isRead: json['is_read'] as bool? ?? false,
        data: json,
      );
}
