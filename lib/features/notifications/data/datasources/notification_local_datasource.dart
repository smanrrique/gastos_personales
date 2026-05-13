import 'package:hive_ce/hive.dart';

import '../../../../core/constants/hive_boxes.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/notification_type.dart';
import '../models/notification_model.dart';

abstract class NotificationLocalDataSource {
  Future<List<NotificationModel>> getAll();
  Future<NotificationModel> add(NotificationModel notification);
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> delete(String id);
  Future<void> clearAll();
  Future<bool> existsFor({
    required AppNotificationType type,
    required String referenceId,
    required String scope,
  });
  Stream<List<NotificationModel>> watchAll();
}

class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  NotificationLocalDataSourceImpl(this._box);
  final Box<NotificationModel> _box;

  @override
  Future<List<NotificationModel>> getAll() async {
    final values = _box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return values;
  }

  @override
  Future<NotificationModel> add(NotificationModel notification) async {
    await _box.put(notification.id, notification);
    return notification;
  }

  @override
  Future<void> markAsRead(String id) async {
    final n = _box.get(id);
    if (n == null) {
      throw const NotFoundException('Notificación no encontrada.');
    }
    n.isRead = true;
    await n.save();
  }

  @override
  Future<void> markAllAsRead() async {
    for (final n in _box.values) {
      if (!n.isRead) {
        n.isRead = true;
        await n.save();
      }
    }
  }

  @override
  Future<void> delete(String id) async {
    if (!_box.containsKey(id)) {
      throw const NotFoundException('Notificación no encontrada.');
    }
    await _box.delete(id);
  }

  @override
  Future<void> clearAll() => _box.clear();

  @override
  Future<bool> existsFor({
    required AppNotificationType type,
    required String referenceId,
    required String scope,
  }) async {
    for (final n in _box.values) {
      if (n.typeIndex == type.index &&
          n.referenceId == referenceId &&
          n.scope == scope) {
        return true;
      }
    }
    return false;
  }

  @override
  Stream<List<NotificationModel>> watchAll() async* {
    yield await getAll();
    yield* _box.watch().asyncMap((_) => getAll());
  }
}

Future<Box<NotificationModel>> openNotificationsBox() async {
  if (Hive.isBoxOpen(HiveBoxes.notifications)) {
    return Hive.box<NotificationModel>(HiveBoxes.notifications);
  }
  return Hive.openBox<NotificationModel>(HiveBoxes.notifications);
}
