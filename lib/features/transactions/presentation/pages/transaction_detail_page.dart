import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../categories/presentation/providers/category_providers.dart';
import '../../domain/entities/transaction.dart';
import '../providers/transaction_providers.dart';
import 'transaction_form_page.dart';

class TransactionDetailPage extends ConsumerWidget {
  const TransactionDetailPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTxs = ref.watch(transactionsStreamProvider);

    return asyncTxs.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
      data: (list) {
        final tx = list.where((t) => t.id == id).cast<Transaction?>().firstWhere(
              (t) => t != null,
              orElse: () => null,
            );
        if (tx == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Movimiento')),
            body: const Center(child: Text('No encontrado.')),
          );
        }
        return _Detail(transaction: tx);
      },
    );
  }
}

class _Detail extends ConsumerWidget {
  const _Detail({required this.transaction});
  final Transaction transaction;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar movimiento'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final result =
        await ref.read(deleteTransactionProvider).call(transaction.id);
    if (!context.mounted) return;
    result.fold(
      (f) => context.showSnack(f.message ?? 'Error al eliminar'),
      (_) {
        context.showSnack('Eliminado');
        context.pop();
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isIncome = transaction.type.isIncome;
    final color = isIncome ? AppColors.income : AppColors.expense;
    final category = ref.watch(categoryByIdProvider(transaction.categoryId));

    return Scaffold(
      appBar: AppBar(
        title: Text(transaction.type.label),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TransactionFormPage(initial: transaction),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _delete(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Center(
            child: Text(
              '${isIncome ? '+' : '-'} ${Formatters.currency(transaction.amount)}',
              style: context.text.displayMedium?.copyWith(color: color),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _DetailRow(label: 'Descripción', value: transaction.description),
          _DetailRow(
            label: 'Categoría',
            value: category?.name ?? 'Sin categoría',
          ),
          _DetailRow(label: 'Fecha', value: Formatters.date(transaction.date)),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: context.text.bodyMedium),
          ),
          Expanded(
            child: Text(value, style: context.text.titleSmall),
          ),
        ],
      ),
    );
  }
}
