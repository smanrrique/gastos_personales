import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/transaction_providers.dart';
import '../widgets/empty_transactions.dart';
import '../widgets/totals_summary_card.dart';
import '../widgets/transaction_tile.dart';

class TransactionsPage extends ConsumerWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTxs = ref.watch(transactionsStreamProvider);
    final totals = ref.watch(transactionTotalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Movimientos'),
        actions: [
          IconButton(
            tooltip: 'Categorías',
            icon: const Icon(Icons.category_outlined),
            onPressed: () => context.push(AppRoutes.categories),
          ),
          IconButton(
            tooltip: 'Estadísticas',
            icon: const Icon(Icons.insights_outlined),
            onPressed: () => context.push(AppRoutes.statistics),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.transactionNew),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
      ),
      body: asyncTxs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Text('Error: $e', style: context.text.bodyMedium),
          ),
        ),
        data: (txs) {
          if (txs.isEmpty) {
            return EmptyTransactions(
              onCreate: () => context.push(AppRoutes.transactionNew),
            );
          }
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: TotalsSummaryCard(totals: totals),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(top: AppSpacing.lg),
                sliver: SliverList.separated(
                  itemCount: txs.length,
                  separatorBuilder: (context, _) =>
                      Divider(height: 1, color: context.colors.outline),
                  itemBuilder: (_, i) => TransactionTile(
                    transaction: txs[i],
                    onTap: () => context.push('/transactions/${txs[i].id}'),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.huge),
              ),
            ],
          );
        },
      ),
    );
  }
}
