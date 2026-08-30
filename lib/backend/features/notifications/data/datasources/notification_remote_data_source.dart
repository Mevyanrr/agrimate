import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/database_tables.dart';
import '../models/app_notification_model.dart';

abstract interface class NotificationRemoteDataSource {
  Future<List<AppNotificationModel>> getMine();
  Future<void> markAsRead(String notificationId);
}

class SupabaseNotificationRemoteDataSource
    implements NotificationRemoteDataSource {
  const SupabaseNotificationRemoteDataSource(this._client);
  final SupabaseClient _client;

  @override
  Future<List<AppNotificationModel>> getMine() async {
    // RLS wajib membatasi hasil ke notifikasi user yang sedang login.
    final rows = await _client.from(DatabaseTables.notifications).select()
        .order('created_at', ascending: false);
    return rows.map(AppNotificationModel.fromJson).toList();
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _client.from(DatabaseTables.notifications)
        .update({'is_read': true}).eq('id', notificationId);
  }
}
