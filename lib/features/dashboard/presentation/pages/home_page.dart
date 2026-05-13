import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../budgets/presentation/providers/budget_providers.dart';
import '../../../budgets/presentation/widgets/budget_card.dart';
import '../../../notifications/presentation/providers/notification_providers.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../../transactions/presentation/widgets/transaction_tile.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTxs = ref.watch(transactionsStreamProvider);
    final totals = ref.watch(transactionTotalsProvider);
    final budgets = ref.watch(budgetsProgressProvider);
    final unread = ref.watch(unreadNotificationsCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            tooltip: 'Notificaciones',
            icon: Badge(
              isLabelVisible: unread > 0,
              label: Text(unread > 9 ? '9+' : '$unread'),
              child: const Icon(Icons.notifications_outlined),
            ),
            onPressed: () => context.push(AppRoutes.notifications),
          ),
          IconButton(
            tooltip: 'Ajustes',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: asyncTxs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (txs) {
          final recent = txs.take(5).toList();
          return ListView(
            children: [
              const SizedBox(height: AppSpacing.sm),
              _BalanceCard(totals: totals),
              const SizedBox(height: AppSpacing.xl),
              _SectionHeader(
                title: 'Acciones rápidas',
                trailing: null,
              ),
              _QuickActions(),
              const SizedBox(height: AppSpacing.xl),
              if (budgets.isNotEmpty) ...[
                _SectionHeader(
                  title: 'Presupuestos del mes',
                  trailing: TextButton(
                    onPressed: () => context.push(AppRoutes.budgets),
                    child: const Text('Ver todos'),
                  ),
                ),
                ...budgets.take(2).map((p) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.sm),
                      child: BudgetCard(progress: p),
                    )),
                const SizedBox(height: AppSpacing.lg),
              ],
              _SectionHeader(
                title: 'Movimientos recientes',
                trailing: TextButton(
                  onPressed: () => context.push(AppRoutes.transactions),
                  child: const Text('Ver todos'),
                ),
              ),
              if (recent.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Center(
                    child: Text('Sin movimientos aún',
                        style: context.text.bodyMedium),
                  ),
                )
              else
                ...recent.map((t) => TransactionTile(
                      transaction: t,
                      onTap: () => context.push('/transactions/${t.id}'),
                    )),
              const SizedBox(height: AppSpacing.huge),
            ],
          );
        },
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.totals});
  final TransactionTotals totals;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.colors.primary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Balance total',
              style: context.text.labelMedium?.copyWith(
                color: context.colors.onPrimary.withValues(alpha: 0.8),
              )),
          const SizedBox(height: AppSpacing.xs),
          Text(
            Formatters.currency(totals.balance),
            style: context.text.displayMedium?.copyWith(
              color: context.colors.onPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _MiniTotal(
                label: 'Ingresos',
                value: totals.income,
                color: AppColors.income,
              ),
              const SizedBox(width: AppSpacing.lg),
              _MiniTotal(
                label: 'Gastos',
                value: totals.expense,
                color: AppColors.expense,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniTotal extends StatelessWidget {
  const _MiniTotal(
      {required this.label, required this.value, required this.color});
  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(label,
                style: context.text.labelSmall?.copyWith(
                  color: context.colors.onPrimary.withValues(alpha: 0.8),
                )),
          ],
        ),
        Text(
          Formatters.currency(value),
          style: context.text.titleSmall
              ?.copyWith(color: context.colors.onPrimary),
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: _ActionTile(
              icon: Icons.add_circle_outline,
              label: 'Movimiento',
              onTap: () => context.push(AppRoutes.transactionNew),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _ActionTile(
              icon: Icons.savings_outlined,
              label: 'Presupuesto',
              onTap: () => context.push(AppRoutes.budgets),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _ActionTile(
              icon: Icons.category_outlined,
              label: 'Categorías',
              onTap: () => context.push(AppRoutes.categories),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile(
      {required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: context.colors.outline),
        ),
        child: Column(
          children: [
            Icon(icon, color: context.colors.primary),
            const SizedBox(height: AppSpacing.xs),
            Text(label, style: context.text.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Text(title, style: context.text.titleSmall),
          const Spacer(),
          ?trailing,
        ],
      ),
    );
  }
}
