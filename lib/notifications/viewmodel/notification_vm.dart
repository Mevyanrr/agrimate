import 'package:agrimate/backend/backend_dependencies.dart';
import 'package:agrimate/backend/core/result/result.dart';
import 'package:agrimate/backend/features/notifications/domain/entities/app_notification.dart';
import 'package:flutter/material.dart';

class NotificationViewModel extends ChangeNotifier {
  final _repository = BackendDependencies.create().notifications;

  List<AppNotification> _items = const [];
  List<AppNotification> get items => _items;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int get unreadCount => _items.where((item) => !item.isRead).length;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getMine();
    switch (result) {
      case Success(data: final data):
        _items = data;
      case Failure(message: final message):
        _errorMessage = message;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(AppNotification notification) async {
    if (notification.isRead) return;
    final result = await _repository.markAsRead(notification.id);
    if (result is Success<void>) await load();
  }

  Future<void> markAllAsRead() async {
    if (unreadCount == 0) return;
    final result = await _repository.markAllAsRead();
    if (result is Success<void>) await load();
  }
}
