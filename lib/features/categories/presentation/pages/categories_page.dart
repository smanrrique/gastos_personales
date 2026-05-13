import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../transactions/domain/entities/transaction_type.dart';
import '../providers/category_providers.dart';
import '../widgets/category_tile.dart';
import 'category_form_page.dart';

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCats = ref.watch(categoriesStreamProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Categorías'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Gastos'),
              Tab(text: 'Ingresos'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CategoryFormPage()),
          ),
          icon: const Icon(Icons.add),
          label: const Text('Nueva'),
        ),
        body: asyncCats.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (cats) {
            final expenses = cats
                .where((c) => c.type == TransactionType.expense)
                .toList();
            final incomes = cats
                .where((c) => c.type == TransactionType.income)
                .toList();
            return TabBarView(
              children: [
                _CategoryList(items: expenses),
                _CategoryList(items: incomes),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CategoryList extends ConsumerWidget {
  const _CategoryList({required this.items});
  final List items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return const Center(child: Text('Sin categorías'));
    }
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, _) =>
          Divider(height: 1, color: context.colors.outline),
      itemBuilder: (_, i) {
        final c = items[i];
        return CategoryTile(
          category: c,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CategoryFormPage(initial: c),
            ),
          ),
          trailing: c.isDefault
              ? Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 2),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceContainerHighest,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text('Por defecto',
                      style: context.text.labelSmall),
                )
              : const Icon(Icons.chevron_right),
        );
      },
    );
  }
}
