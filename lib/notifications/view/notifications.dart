import 'package:agrimate/backend/features/notifications/domain/entities/app_notification.dart';
import 'package:agrimate/notifications/viewmodel/notification_vm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificationViewModel()..load(),
      child: const _NotificationsBody(),
    );
  }
}

class _NotificationsBody extends StatelessWidget {
  const _NotificationsBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotificationViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          TextButton(
            onPressed: vm.unreadCount == 0 ? null : vm.markAllAsRead,
            child: const Text('Baca semua'),
          ),
        ],
      ),
      body: RefreshIndicator(onRefresh: vm.load, child: _content(context, vm)),
    );
  }

  Widget _content(BuildContext context, NotificationViewModel vm) {
    if (vm.isLoading && vm.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.errorMessage != null && vm.items.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 160),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(vm.errorMessage!, textAlign: TextAlign.center),
          ),
        ],
      );
    }
    if (vm.items.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 160),
          Icon(Icons.notifications_none, size: 64),
          SizedBox(height: 12),
          Text('Belum ada notifikasi', textAlign: TextAlign.center),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: vm.items.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = vm.items[index];
        return ListTile(
          leading: Icon(
            item.isRead ? Icons.circle_outlined : Icons.circle,
            size: 13,
            color: item.isRead ? Colors.grey : Theme.of(context).primaryColor,
          ),
          title: Text(
            item.title,
            style: TextStyle(
              fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          subtitle: Text('${item.message}\n${_relativeTime(item.createdAt)}'),
          isThreeLine: true,
          onTap: () => _openNotification(context, vm, item),
        );
      },
    );
  }

  Future<void> _openNotification(
    BuildContext context,
    NotificationViewModel vm,
    AppNotification notification,
  ) async {
    await vm.markAsRead(notification);
    if (!context.mounted || notification.referenceId == null) return;

    final target = switch (notification.referenceType) {
      'MATCH' => 'detail kecocokan',
      'TRANSACTION' => 'detail transaksi',
      _ => null,
    };
    if (target != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Navigasi ke $target akan ditambahkan berikutnya.'),
        ),
      );
    }
  }

  String _relativeTime(DateTime createdAt) {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inMinutes < 1) return 'Baru saja';
    if (difference.inHours < 1) return '${difference.inMinutes} menit lalu';
    if (difference.inDays < 1) return '${difference.inHours} jam lalu';
    return '${difference.inDays} hari lalu';
  }
}
