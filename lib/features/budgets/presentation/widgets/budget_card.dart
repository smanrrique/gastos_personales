import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../categories/presentation/providers/category_providers.dart';
import '../../../categories/presentation/widgets/category_avatar.dart';
import '../../domain/entities/budget.dart';

class BudgetCard extends ConsumerWidget {
  const BudgetCard({
    super.key,
    required this.progress,
    this.onTap,
  });

  final BudgetProgress progress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budget = progress.budget;
    final category =
        ref.watch(categoryByIdProvider(budget.categoryId));
    final percent = progress.percentUsed.clamp(0.0, 1.0).toDouble();
    final color = progress.isOverBudget
        ? AppColors.expense
        : progress.isOverThreshold
            ? AppColors.warning
            : AppColors.income;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
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
                if (category != null)
                  CategoryAvatar(
                    iconKey: category.iconKey,
                    colorKey: category.colorKey,
                    size: 36,
                  )
                else
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: context.colors.primary.withValues(alpha: 0.12),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Icon(Icons.account_balance_wallet_outlined,
                        color: context.colors.primary, size: 20),
                  ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(budget.name, style: context.text.titleSmall),
                      Text(
                        category?.name ?? 'Todas las categorías',
                        style: context.text.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (progress.isOverBudget)
                  Icon(Icons.warning_amber_rounded,
                      color: AppColors.expense, size: 20),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 8,
                backgroundColor:
                    context.colors.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Text(
                  Formatters.currency(progress.spent),
                  style: context.text.titleSmall?.copyWith(color: color),
                ),
                Text(
                  '  /  ${Formatters.currency(progress.limit)}',
                  style: context.text.bodyMedium,
                ),
                const Spacer(),
                Text(
                  '${(progress.percentUsed * 100).toStringAsFixed(0)}%',
                  style: context.text.labelLarge?.copyWith(color: color),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
