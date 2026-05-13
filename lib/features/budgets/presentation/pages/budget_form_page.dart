import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../categories/presentation/providers/category_providers.dart';
import '../../../categories/presentation/widgets/category_avatar.dart';
import '../../../categories/presentation/widgets/category_picker_sheet.dart';
import '../../../transactions/domain/entities/transaction_type.dart';
import '../../domain/entities/budget.dart';
import '../../domain/usecases/create_budget.dart';
import '../providers/budget_providers.dart';

class BudgetFormPage extends ConsumerStatefulWidget {
  const BudgetFormPage({super.key, this.initial});

  final Budget? initial;
  bool get isEditing => initial != null;

  @override
  ConsumerState<BudgetFormPage> createState() => _BudgetFormPageState();
}

class _BudgetFormPageState extends ConsumerState<BudgetFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _amountCtrl;
  String? _categoryId;
  double _threshold = 0.8;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final b = widget.initial;
    _nameCtrl = TextEditingController(text: b?.name ?? '');
    _amountCtrl = TextEditingController(
      text: b != null ? b.amount.toStringAsFixed(0) : '',
    );
    _categoryId = b?.categoryId;
    _threshold = b?.alertThreshold ?? 0.8;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickCategory() async {
    final result = await CategoryPickerSheet.show(
      context,
      type: TransactionType.expense,
      selectedId: _categoryId,
    );
    if (result != null) setState(() => _categoryId = result.id);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final amount = Formatters.parseAmount(_amountCtrl.text) ?? 0;
    final name = _nameCtrl.text.trim();

    final result = widget.isEditing
        ? await ref.read(updateBudgetProvider).call(
              widget.initial!.copyWith(
                name: name,
                amount: amount,
                categoryId: _categoryId,
                alertThreshold: _threshold,
              ),
            )
        : await ref.read(createBudgetProvider).call(
              CreateBudgetParams(
                id: const Uuid().v4(),
                name: name,
                amount: amount,
                alertThreshold: _threshold,
                categoryId: _categoryId,
              ),
            );

    if (!mounted) return;
    setState(() => _saving = false);
    result.fold(
      (f) => context.showSnack(f.message ?? 'Error al guardar'),
      (_) {
        context.showSnack(widget.isEditing ? 'Actualizado' : 'Guardado');
        Navigator.of(context).pop();
      },
    );
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar presupuesto'),
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
        await ref.read(deleteBudgetProvider).call(widget.initial!.id);
    if (!mounted) return;
    result.fold(
      (f) => context.showSnack(f.message ?? 'Error al eliminar'),
      (_) {
        context.showSnack('Eliminado');
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final category = ref.watch(categoryByIdProvider(_categoryId));
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing
            ? 'Editar presupuesto'
            : 'Nuevo presupuesto'),
        actions: [
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                hintText: 'Ej: Comida del mes',
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Nombre requerido';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Límite mensual',
                prefixText: r'$ ',
              ),
              validator: (v) {
                final value = Formatters.parseAmount(v ?? '');
                if (value == null || value <= 0) {
                  return 'Ingresa un monto válido';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            InkWell(
              onTap: _pickCategory,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Categoría (opcional)',
                  suffixIcon: _categoryId != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () =>
                              setState(() => _categoryId = null),
                        )
                      : const Icon(Icons.chevron_right),
                ),
                child: Row(
                  children: [
                    if (category != null) ...[
                      CategoryAvatar(
                        iconKey: category.iconKey,
                        colorKey: category.colorKey,
                        size: 32,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(category.name,
                          style: context.text.titleSmall),
                    ] else
                      Text('Todas las categorías',
                          style: context.text.bodyMedium),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Alerta al ${(_threshold * 100).round()}% del presupuesto',
              style: context.text.labelLarge,
            ),
            Slider(
              value: _threshold,
              min: 0.5,
              max: 1.0,
              divisions: 10,
              label: '${(_threshold * 100).round()}%',
              onChanged: (v) => setState(() => _threshold = v),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            FilledButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.isEditing ? 'Actualizar' : 'Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
