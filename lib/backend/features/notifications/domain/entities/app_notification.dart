class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.referenceType,
    this.referenceId,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String type;
  final String title;
  final String message;
  final String? referenceType;
  final String? referenceId;
  final bool isRead;
  final DateTime createdAt;
}
