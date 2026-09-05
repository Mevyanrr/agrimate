import '../../domain/entities/app_notification.dart';

class AppNotificationModel extends AppNotification {
  const AppNotificationModel({
    required super.id,
    required super.type,
    required super.title,
    required super.message,
    super.referenceType,
    super.referenceId,
    required super.isRead,
    required super.createdAt,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) =>
      AppNotificationModel(
        id: json['id'].toString(),
        type: json['type'] as String,
        title: json['title'] as String,
        message: json['message'] as String,
        referenceType: json['reference_type'] as String?,
        referenceId: json['reference_id']?.toString(),
        isRead: json['is_read'] as bool? ?? false,
        createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      );
}
