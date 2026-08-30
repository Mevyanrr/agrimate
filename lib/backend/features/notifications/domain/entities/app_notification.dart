class AppNotification {
  const AppNotification({
    required this.id,
    required this.isRead,
    required this.data,
  });
  final String id;
  final bool isRead;

  /// TODO: Ganti dengan field typed (title, body, type, createdAt) sesuai schema.
  final Map<String, dynamic> data;
}
