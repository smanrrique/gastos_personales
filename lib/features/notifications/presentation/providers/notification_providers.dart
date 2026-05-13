import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/notification_local_datasource.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';

final notificationsBoxProvider =
    FutureProvider((ref) => openNotificationsBox());

final notificationLocalDataSourceProvider =
    Provider<NotificationLocalDataSource>((ref) {
  final box = ref.watch(notificationsBoxProvider).requireValue;
  return NotificationLocalDataSourceImpl(box);
});

final notificationRepositoryProvider =
    Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(
      ref.watch(notificationLocalDataSourceProvider));
});

final notificationsStreamProvider =
    StreamProvider<List<AppNotification>>((ref) {
  ref.watch(notificationsBoxProvider);
  return ref.watch(notificationRepositoryProvider).watchAll();
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final list = ref.watch(notificationsStreamProvider).maybeWhen(
        data: (d) => d,
        orElse: () => const <AppNotification>[],
      );
  return list.where((n) => !n.isRead).length;
});
