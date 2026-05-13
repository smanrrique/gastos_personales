import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../categories/presentation/widgets/category_color_library.dart';
import '../../domain/entities/period.dart';

class CategoryPieChart extends StatelessWidget {
  const CategoryPieChart({super.key, required this.items});

  final List<CategoryBreakdownItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Center(
          child: Text(
            'No hay gastos en el periodo',
            style: context.text.bodyMedium,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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
            Text('Gastos por categoría', style: context.text.titleSmall),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 56,
                  startDegreeOffset: -90,
                  sections: items.map((i) {
                    final color = CategoryColorLibrary.get(i.colorKey);
                    return PieChartSectionData(
                      color: color,
                      value: i.amount,
                      radius: 28,
                      showTitle: false,
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ...items.map((i) => _LegendRow(item: i)),
          ],
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.item});
  final CategoryBreakdownItem item;

  @override
  Widget build(BuildContext context) {
    final color = CategoryColorLibrary.get(item.colorKey);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(item.categoryName, style: context.text.bodyMedium),
          ),
          Text(
            '${(item.percent * 100).toStringAsFixed(0)}%  ·  ${Formatters.currency(item.amount)}',
            style: context.text.labelSmall,
          ),
        ],
      ),
    );
  }
}
