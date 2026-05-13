import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/statistics_providers.dart';

class TotalsHeader extends StatelessWidget {
  const TotalsHeader({super.key, required this.totals});

  final PeriodTotals totals;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: _Card(
              label: 'Ingresos',
              amount: totals.income,
              color: AppColors.income,
              icon: Icons.arrow_upward_rounded,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _Card(
              label: 'Gastos',
              amount: totals.expense,
              color: AppColors.expense,
              icon: Icons.arrow_downward_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: context.colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: AppSpacing.xs),
              Text(label, style: context.text.labelMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            Formatters.currency(amount),
            style: context.text.titleLarge?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
