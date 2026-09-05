import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/database_tables.dart';
import '../../../../core/errors/backend_exception.dart';
import '../models/app_notification_model.dart';

abstract interface class NotificationRemoteDataSource {
  Future<List<AppNotificationModel>> getMine();
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
  Future<int> getUnreadCount();
}

class SupabaseNotificationRemoteDataSource
    implements NotificationRemoteDataSource {
  const SupabaseNotificationRemoteDataSource(this._client);
  final SupabaseClient _client;

  String get _userId =>
      _client.auth.currentUser?.id ??
      (throw const BackendException(
        'Pengguna belum login.',
        code: 'unauthenticated',
      ));

  @override
  Future<List<AppNotificationModel>> getMine() async {
    final rows = await _client
        .from(DatabaseTables.notifications)
        .select()
        .eq('user_id', _userId)
        .order('created_at', ascending: false);
    return rows.map(AppNotificationModel.fromJson).toList();
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _client
        .from(DatabaseTables.notifications)
        .update({'is_read': true})
        .eq('id', notificationId)
        .eq('user_id', _userId);
  }

  @override
  Future<void> markAllAsRead() async {
    await _client
        .from(DatabaseTables.notifications)
        .update({'is_read': true})
        .eq('user_id', _userId)
        .eq('is_read', false);
  }

  @override
  Future<int> getUnreadCount() async {
    final rows = await _client
        .from(DatabaseTables.notifications)
        .select('id')
        .eq('user_id', _userId)
        .eq('is_read', false);
    return rows.length;
  }
}
