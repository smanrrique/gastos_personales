import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/providers/category_providers.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/entities/transaction_type.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../domain/entities/period.dart';

final selectedPeriodProvider =
    StateProvider<StatsPeriod>((_) => StatsPeriod.thisMonth());

final periodTransactionsProvider = Provider<List<Transaction>>((ref) {
  final period = ref.watch(selectedPeriodProvider);
  final txs = ref.watch(transactionsStreamProvider).maybeWhen(
        data: (d) => d,
        orElse: () => const <Transaction>[],
      );
  return txs
      .where((t) =>
          !t.date.isBefore(period.start) && !t.date.isAfter(period.end))
      .toList();
});

class PeriodTotals {
  const PeriodTotals(this.income, this.expense);
  final double income;
  final double expense;
  double get balance => income - expense;
}

final periodTotalsProvider = Provider<PeriodTotals>((ref) {
  double income = 0, expense = 0;
  for (final t in ref.watch(periodTransactionsProvider)) {
    if (t.type.isIncome) {
      income += t.amount;
    } else {
      expense += t.amount;
    }
  }
  return PeriodTotals(income, expense);
});

final expensesByCategoryProvider =
    Provider<List<CategoryBreakdownItem>>((ref) {
  final txs = ref
      .watch(periodTransactionsProvider)
      .where((t) => t.type == TransactionType.expense)
      .toList();
  final cats = ref.watch(categoriesStreamProvider).maybeWhen(
        data: (d) => d,
        orElse: () => const <Category>[],
      );
  if (txs.isEmpty) return const [];

  final Map<String?, double> totals = {};
  for (final t in txs) {
    totals.update(t.categoryId, (v) => v + t.amount,
        ifAbsent: () => t.amount);
  }

  final total = totals.values.fold<double>(0, (a, b) => a + b);
  final items = totals.entries.map((e) {
    final cat = e.key == null
        ? null
        : cats.cast<Category?>().firstWhere(
              (c) => c?.id == e.key,
              orElse: () => null,
            );
    return CategoryBreakdownItem(
      categoryId: e.key,
      categoryName: cat?.name ?? 'Sin categoría',
      iconKey: cat?.iconKey ?? 'other',
      colorKey: cat?.colorKey ?? 'grey',
      amount: e.value,
      percent: total == 0 ? 0 : e.value / total,
    );
  }).toList()
    ..sort((a, b) => b.amount.compareTo(a.amount));

  return items;
});

final monthlySeriesProvider = Provider<List<MonthlyPoint>>((ref) {
  final txs = ref.watch(transactionsStreamProvider).maybeWhen(
        data: (d) => d,
        orElse: () => const <Transaction>[],
      );
  if (txs.isEmpty) return const [];

  final now = DateTime.now();
  final List<MonthlyPoint> series = [];
  for (int i = 5; i >= 0; i--) {
    final monthStart = DateTime(now.year, now.month - i);
    final monthEnd = DateTime(now.year, now.month - i + 1)
        .subtract(const Duration(milliseconds: 1));
    double income = 0, expense = 0;
    for (final t in txs) {
      if (t.date.isBefore(monthStart) || t.date.isAfter(monthEnd)) continue;
      if (t.type.isIncome) {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }
    series.add(MonthlyPoint(month: monthStart, income: income, expense: expense));
  }
  return series;
});
