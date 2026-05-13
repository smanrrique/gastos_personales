import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/app_notification.dart';
import '../entities/notification_type.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<AppNotification>>> getAll();
  Future<Either<Failure, AppNotification>> add(AppNotification notification);
  Future<Either<Failure, Unit>> markAsRead(String id);
  Future<Either<Failure, Unit>> markAllAsRead();
  Future<Either<Failure, Unit>> delete(String id);
  Future<Either<Failure, Unit>> clearAll();
  Future<bool> existsFor({
    required AppNotificationType type,
    required String referenceId,
    required String scope,
  });
  Stream<List<AppNotification>> watchAll();
}
