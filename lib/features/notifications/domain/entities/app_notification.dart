import 'package:equatable/equatable.dart';

import 'notification_type.dart';

class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.referenceId,
    this.scope,
    this.isRead = false,
  });

  final String id;
  final AppNotificationType type;
  final String title;
  final String body;
  final String? referenceId; // ej: budgetId
  final String? scope;       // ej: "2026-05" para idempotencia mensual
  final DateTime createdAt;
  final bool isRead;

  AppNotification copyWith({
    String? id,
    AppNotificationType? type,
    String? title,
    String? body,
    String? referenceId,
    String? scope,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      referenceId: referenceId ?? this.referenceId,
      scope: scope ?? this.scope,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  List<Object?> get props =>
      [id, type, title, body, referenceId, scope, createdAt, isRead];
}
