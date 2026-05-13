import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/period.dart';
import '../providers/statistics_providers.dart';

class PeriodSelector extends ConsumerWidget {
  const PeriodSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(selectedPeriodProvider);
    final options = [
      StatsPeriod.thisMonth(),
      StatsPeriod.lastMonth(),
      StatsPeriod.thisYear(),
    ];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (_, i) {
          final p = options[i];
          final selected = current.label == p.label;
          return ChoiceChip(
            label: Text(p.label),
            selected: selected,
            onSelected: (_) =>
                ref.read(selectedPeriodProvider.notifier).state = p,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              side: BorderSide(
                color: selected
                    ? context.colors.primary
                    : context.colors.outline,
              ),
            ),
          );
        },
      ),
    );
  }
}
