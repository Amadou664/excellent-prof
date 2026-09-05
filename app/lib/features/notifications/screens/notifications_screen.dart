import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/notification_model.dart';
import '../../../providers/notifications_provider.dart';
import '../../../providers/repository_providers.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/loading_indicator.dart';

/// Centre de notifications. `GET /notifications/mine`,
/// `PATCH /notifications/:id/read`, `PATCH /notifications/read-all`.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          notificationsAsync.maybeWhen(
            data: (page) => page.unreadCount > 0
                ? TextButton(
                    onPressed: () async {
                      await ref.read(notificationRepositoryProvider).markAllRead();
                      ref.invalidate(notificationsProvider);
                    },
                    child: const Text('Tout marquer lu', style: TextStyle(color: Colors.white)),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(notificationsProvider)),
        data: (page) {
          if (page.items.isEmpty) {
            return const EmptyState(
              message: 'Aucune notification pour le moment.',
              icon: Icons.notifications_none,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(notificationsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: page.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 4),
              itemBuilder: (context, index) => _NotificationTile(notification: page.items[index]),
            ),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.notification});

  final NotificationModel notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: notification.lue ? null : AppColors.paleGold.withValues(alpha: 0.35),
      child: ListTile(
        leading: Icon(
          notification.lue ? Icons.notifications_none : Icons.notifications_active,
          color: notification.lue ? AppColors.textSecondary : AppColors.primaryDarkGreen,
        ),
        title: Text(
          notification.titre,
          style: TextStyle(fontWeight: notification.lue ? FontWeight.normal : FontWeight.bold),
        ),
        subtitle: Text(notification.corps),
        trailing: Text(
          DateFormat('dd/MM HH:mm').format(notification.createdAt),
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        onTap: notification.lue
            ? null
            : () async {
                await ref.read(notificationRepositoryProvider).markRead(notification.id);
                ref.invalidate(notificationsProvider);
              },
      ),
    );
  }
}
