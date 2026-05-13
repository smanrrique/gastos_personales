import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../../budgets/domain/entities/budget.dart';
import '../../../budgets/presentation/providers/budget_providers.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/entities/notification_type.dart';
import 'notification_providers.dart';

/// Observa el progreso de presupuestos del mes y dispara alertas locales
/// idempotentes (una por presupuesto/mes/tipo).
final budgetAlertObserverProvider = Provider<void>((ref) {
  ref.listen<List<BudgetProgress>>(
    budgetsProgressProvider,
    (previous, next) async {
      final repo = ref.read(notificationRepositoryProvider);
      const uuid = Uuid();
      final scope = _monthScope(DateTime.now());

      for (final p in next) {
        if (p.isOverBudget) {
          await _emitIfNew(
            repo: repo,
            uuid: uuid,
            scope: scope,
            type: AppNotificationType.budgetExceeded,
            budget: p.budget,
            title: 'Presupuesto excedido',
            body:
                'Has superado el límite de "${p.budget.name}" (${Formatters.currency(p.spent)} / ${Formatters.currency(p.limit)}).',
          );
        } else if (p.isOverThreshold) {
          await _emitIfNew(
            repo: repo,
            uuid: uuid,
            scope: scope,
            type: AppNotificationType.budgetAlert,
            budget: p.budget,
            title: 'Alerta de presupuesto',
            body:
                'Estás al ${(p.percentUsed * 100).toStringAsFixed(0)}% de "${p.budget.name}".',
          );
        }
      }
    },
    fireImmediately: true,
  );
});

String _monthScope(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}';

Future<void> _emitIfNew({
  required dynamic repo,
  required Uuid uuid,
  required String scope,
  required AppNotificationType type,
  required Budget budget,
  required String title,
  required String body,
}) async {
  final exists = await repo.existsFor(
    type: type,
    referenceId: budget.id,
    scope: scope,
  );
  if (exists) return;

  final notification = AppNotification(
    id: uuid.v4(),
    type: type,
    title: title,
    body: body,
    referenceId: budget.id,
    scope: scope,
    createdAt: DateTime.now(),
  );

  await repo.add(notification);
  await NotificationService.show(
    id: budget.id.hashCode ^ type.index,
    title: title,
    body: body,
    payload: 'budget:${budget.id}',
  );
}
