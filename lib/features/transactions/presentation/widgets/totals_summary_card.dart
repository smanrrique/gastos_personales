import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/transaction_providers.dart';

class TotalsSummaryCard extends StatelessWidget {
  const TotalsSummaryCard({super.key, required this.totals});

  final TransactionTotals totals;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.colors.primary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Balance del mes',
            style: context.text.labelMedium?.copyWith(
              color: context.colors.onPrimary.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            Formatters.currency(totals.balance),
            style: context.text.displaySmall
                ?.copyWith(color: context.colors.onPrimary),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _Pill(
                label: 'Ingresos',
                amount: totals.income,
                color: AppColors.income,
                icon: Icons.arrow_upward_rounded,
              ),
              const SizedBox(width: AppSpacing.md),
              _Pill(
                label: 'Gastos',
                amount: totals.expense,
                color: AppColors.expense,
                icon: Icons.arrow_downward_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  label,
                  style: context.text.labelSmall
                      ?.copyWith(color: context.colors.onPrimary),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              Formatters.currency(amount),
              style: context.text.titleMedium
                  ?.copyWith(color: context.colors.onPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
