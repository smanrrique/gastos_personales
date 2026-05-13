import 'package:hive_ce/hive.dart';

import '../../domain/entities/app_notification.dart';
import '../../domain/entities/notification_type.dart';

part 'notification_model.g.dart';

@HiveType(typeId: 3)
class NotificationModel extends HiveObject {
  NotificationModel({
    required this.id,
    required this.typeIndex,
    required this.title,
    required this.body,
    required this.createdAt,
    this.referenceId,
    this.scope,
    this.isRead = false,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  int typeIndex;

  @HiveField(2)
  String title;

  @HiveField(3)
  String body;

  @HiveField(4)
  String? referenceId;

  @HiveField(5)
  String? scope;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  bool isRead;

  AppNotificationType get type => AppNotificationType.values[typeIndex];

  AppNotification toEntity() => AppNotification(
        id: id,
        type: type,
        title: title,
        body: body,
        referenceId: referenceId,
        scope: scope,
        createdAt: createdAt,
        isRead: isRead,
      );

  factory NotificationModel.fromEntity(AppNotification n) => NotificationModel(
        id: n.id,
        typeIndex: n.type.index,
        title: n.title,
        body: n.body,
        referenceId: n.referenceId,
        scope: n.scope,
        createdAt: n.createdAt,
        isRead: n.isRead,
      );
}
