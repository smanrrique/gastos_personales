import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/notification_providers.dart';
import '../widgets/notification_tile.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncNotifs = ref.watch(notificationsStreamProvider);
    final repo = ref.watch(notificationRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          asyncNotifs.maybeWhen(
            data: (list) => list.isEmpty
                ? const SizedBox.shrink()
                : PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'mark') await repo.markAllAsRead();
                      if (v == 'clear') await repo.clearAll();
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'mark',
                        child: Text('Marcar todas como leídas'),
                      ),
                      PopupMenuItem(
                        value: 'clear',
                        child: Text('Eliminar todas'),
                      ),
                    ],
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: asyncNotifs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.notifications_none_rounded,
                        size: 64, color: context.colors.outline),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Sin notificaciones',
                        style: context.text.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Las alertas de tus presupuestos y otras notificaciones aparecerán aquí.',
                      style: context.text.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (context, _) =>
                Divider(height: 1, color: context.colors.outline),
            itemBuilder: (_, i) {
              final n = list[i];
              return NotificationTile(
                notification: n,
                onTap: () {
                  if (!n.isRead) repo.markAsRead(n.id);
                },
                onDismissed: () => repo.delete(n.id),
              );
            },
          );
        },
      ),
    );
  }
}
