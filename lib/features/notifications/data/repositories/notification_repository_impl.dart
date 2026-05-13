import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/entities/notification_type.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_local_datasource.dart';
import '../models/notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._local);
  final NotificationLocalDataSource _local;

  @override
  Future<Either<Failure, List<AppNotification>>> getAll() async {
    try {
      final models = await _local.getAll();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppNotification>> add(AppNotification n) async {
    try {
      final saved = await _local.add(NotificationModel.fromEntity(n));
      return Right(saved.toEntity());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> markAsRead(String id) async {
    try {
      await _local.markAsRead(id);
      return const Right(unit);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> markAllAsRead() async {
    try {
      await _local.markAllAsRead();
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> delete(String id) async {
    try {
      await _local.delete(id);
      return const Right(unit);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearAll() async {
    try {
      await _local.clearAll();
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<bool> existsFor({
    required AppNotificationType type,
    required String referenceId,
    required String scope,
  }) =>
      _local.existsFor(type: type, referenceId: referenceId, scope: scope);

  @override
  Stream<List<AppNotification>> watchAll() =>
      _local.watchAll().map((list) => list.map((m) => m.toEntity()).toList());
}
