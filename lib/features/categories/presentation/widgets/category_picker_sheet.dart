import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../transactions/domain/entities/transaction_type.dart';
import '../../domain/entities/category.dart';
import '../providers/category_providers.dart';
import 'category_avatar.dart';

class CategoryPickerSheet extends ConsumerWidget {
  const CategoryPickerSheet({
    super.key,
    required this.type,
    this.selectedId,
  });

  final TransactionType type;
  final String? selectedId;

  static Future<Category?> show(
    BuildContext context, {
    required TransactionType type,
    String? selectedId,
  }) {
    return showModalBottomSheet<Category?>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) =>
          CategoryPickerSheet(type: type, selectedId: selectedId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesByTypeProvider(type));

    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: 0.9,
      initialChildSize: 0.6,
      builder: (_, controller) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            child: Row(
              children: [
                Text('Seleccionar categoría',
                    style: context.text.titleMedium),
                const Spacer(),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: GridView.builder(
              controller: controller,
              padding: const EdgeInsets.all(AppSpacing.lg),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 0.95,
              ),
              itemCount: categories.length,
              itemBuilder: (_, i) {
                final c = categories[i];
                final selected = c.id == selectedId;
                return InkWell(
                  onTap: () => Navigator.of(context).pop(c),
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusMd),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(
                        color: selected
                            ? context.colors.primary
                            : context.colors.outline,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CategoryAvatar(
                          iconKey: c.iconKey,
                          colorKey: c.colorKey,
                          size: 40,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          c.name,
                          style: context.text.labelSmall,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
