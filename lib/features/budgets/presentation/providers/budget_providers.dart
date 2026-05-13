import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/datetime_extensions.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/entities/transaction_type.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../data/datasources/budget_local_datasource.dart';
import '../../data/repositories/budget_repository_impl.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../../domain/usecases/create_budget.dart';
import '../../domain/usecases/delete_budget.dart';
import '../../domain/usecases/update_budget.dart';
import '../../domain/usecases/watch_budgets.dart';

// ── Datasource / Repo / Use cases ──────────────────────────
final budgetsBoxProvider = FutureProvider((ref) => openBudgetsBox());

final budgetLocalDataSourceProvider = Provider<BudgetLocalDataSource>((ref) {
  final box = ref.watch(budgetsBoxProvider).requireValue;
  return BudgetLocalDataSourceImpl(box);
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepositoryImpl(ref.watch(budgetLocalDataSourceProvider));
});

final createBudgetProvider =
    Provider((ref) => CreateBudget(ref.watch(budgetRepositoryProvider)));
final updateBudgetProvider =
    Provider((ref) => UpdateBudget(ref.watch(budgetRepositoryProvider)));
final deleteBudgetProvider =
    Provider((ref) => DeleteBudget(ref.watch(budgetRepositoryProvider)));
final watchBudgetsProvider =
    Provider((ref) => WatchBudgets(ref.watch(budgetRepositoryProvider)));

// ── Streams ────────────────────────────────────────────────
final budgetsStreamProvider = StreamProvider<List<Budget>>((ref) {
  ref.watch(budgetsBoxProvider);
  return ref.watch(watchBudgetsProvider).call();
});

/// Progreso del presupuesto en el mes actual.
final budgetProgressProvider =
    Provider.family<BudgetProgress, Budget>((ref, budget) {
  final now = DateTime.now();
  final start = now.startOfMonth;
  final end = now.endOfMonth;
  final txs = ref.watch(transactionsStreamProvider).maybeWhen(
        data: (d) => d,
        orElse: () => const <Transaction>[],
      );
  final spent = txs
      .where((t) => t.type == TransactionType.expense)
      .where((t) =>
          t.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
          t.date.isBefore(end.add(const Duration(seconds: 1))))
      .where((t) =>
          budget.categoryId == null || t.categoryId == budget.categoryId)
      .fold<double>(0, (sum, t) => sum + t.amount);
  return BudgetProgress(budget: budget, spent: spent);
});

final budgetsProgressProvider = Provider<List<BudgetProgress>>((ref) {
  final budgets = ref.watch(budgetsStreamProvider).maybeWhen(
        data: (d) => d,
        orElse: () => const <Budget>[],
      );
  return budgets
      .where((b) => b.isActive)
      .map((b) => ref.watch(budgetProgressProvider(b)))
      .toList();
});
