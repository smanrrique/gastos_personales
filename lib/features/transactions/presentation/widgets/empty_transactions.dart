import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';

class EmptyTransactions extends StatelessWidget {
  const EmptyTransactions({super.key, this.onCreate});

  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: context.colors.outline,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Aún no registras movimientos',
              style: context.text.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Agrega tu primer ingreso o gasto para comenzar.',
              style: context.text.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onCreate != null) ...[
              const SizedBox(height: AppSpacing.xl),
              FilledButton.icon(
                onPressed: onCreate,
                icon: const Icon(Icons.add),
                label: const Text('Registrar movimiento'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
