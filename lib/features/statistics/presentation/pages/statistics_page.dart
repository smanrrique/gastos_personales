import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../providers/statistics_providers.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/monthly_bar_chart.dart';
import '../widgets/period_selector.dart';
import '../widgets/totals_header.dart';

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totals = ref.watch(periodTotalsProvider);
    final breakdown = ref.watch(expensesByCategoryProvider);
    final monthly = ref.watch(monthlySeriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: ListView(
        children: [
          const SizedBox(height: AppSpacing.sm),
          const PeriodSelector(),
          const SizedBox(height: AppSpacing.lg),
          TotalsHeader(totals: totals),
          const SizedBox(height: AppSpacing.lg),
          CategoryPieChart(items: breakdown),
          const SizedBox(height: AppSpacing.lg),
          MonthlyBarChart(series: monthly),
          const SizedBox(height: AppSpacing.huge),
        ],
      ),
    );
  }
}
