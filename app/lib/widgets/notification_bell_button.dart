import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/router/app_routes.dart';
import '../providers/notifications_provider.dart';

/// Icône de cloche avec badge (nombre de notifications non lues), à placer
/// dans les `AppBar.actions` des dashboards. `GET /notifications/mine`.
class NotificationBellButton extends ConsumerWidget {
  const NotificationBellButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(notificationsProvider).maybeWhen(
          data: (page) => page.unreadCount,
          orElse: () => 0,
        );

    return IconButton(
      tooltip: 'Notifications',
      onPressed: () async {
        await context.push(AppRoutes.notifications);
        ref.invalidate(notificationsProvider);
      },
      icon: Badge(
        label: Text('$unreadCount'),
        isLabelVisible: unreadCount > 0,
        child: const Icon(Icons.notifications_outlined),
      ),
    );
  }
}
