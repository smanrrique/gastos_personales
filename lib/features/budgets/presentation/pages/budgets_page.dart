import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/budget_providers.dart';
import '../widgets/budget_card.dart';
import 'budget_form_page.dart';

class BudgetsPage extends ConsumerWidget {
  const BudgetsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncBudgets = ref.watch(budgetsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Presupuestos')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const BudgetFormPage()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
      ),
      body: asyncBudgets.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (budgets) {
          if (budgets.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.savings_outlined,
                        size: 64, color: context.colors.outline),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Sin presupuestos definidos',
                        style: context.text.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Define un límite mensual para tus gastos por categoría.',
                      style: context.text.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          final progressList = ref.watch(budgetsProgressProvider);
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: progressList.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppSpacing.md),
            itemBuilder: (_, i) => BudgetCard(
              progress: progressList[i],
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      BudgetFormPage(initial: progressList[i].budget),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
