import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../categories/presentation/providers/category_providers.dart';
import '../../../categories/presentation/widgets/category_avatar.dart';
import '../../../categories/presentation/widgets/category_picker_sheet.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_type.dart';
import '../../domain/usecases/create_transaction.dart';
import '../providers/transaction_providers.dart';

class TransactionFormPage extends ConsumerStatefulWidget {
  const TransactionFormPage({super.key, this.initial});

  final Transaction? initial;

  bool get isEditing => initial != null;

  @override
  ConsumerState<TransactionFormPage> createState() =>
      _TransactionFormPageState();
}

class _TransactionFormPageState extends ConsumerState<TransactionFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountCtrl;
  late final TextEditingController _descCtrl;
  late TransactionType _type;
  late DateTime _date;
  String? _categoryId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _amountCtrl = TextEditingController(
      text: initial != null ? initial.amount.toStringAsFixed(0) : '',
    );
    _descCtrl = TextEditingController(text: initial?.description ?? '');
    _type = initial?.type ?? TransactionType.expense;
    _date = initial?.date ?? DateTime.now();
    _categoryId = initial?.categoryId;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickCategory() async {
    final result = await CategoryPickerSheet.show(
      context,
      type: _type,
      selectedId: _categoryId,
    );
    if (result != null) setState(() => _categoryId = result.id);
  }

  void _onTypeChanged(TransactionType v) {
    setState(() {
      _type = v;
      // Si la categoría no aplica al nuevo tipo, limpiar.
      final cat = ref.read(categoryByIdProvider(_categoryId));
      if (cat != null && cat.type != v) _categoryId = null;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final amount = Formatters.parseAmount(_amountCtrl.text) ?? 0;
    final description = _descCtrl.text.trim();

    final result = widget.isEditing
        ? await ref.read(updateTransactionProvider).call(
              widget.initial!.copyWith(
                amount: amount,
                type: _type,
                description: description,
                date: _date,
                categoryId: _categoryId,
              ),
            )
        : await ref.read(createTransactionProvider).call(
              CreateTransactionParams(
                id: const Uuid().v4(),
                amount: amount,
                type: _type,
                description: description,
                date: _date,
                categoryId: _categoryId,
              ),
            );

    if (!mounted) return;
    setState(() => _saving = false);

    result.fold(
      (failure) => context.showSnack(failure.message ?? 'Error al guardar'),
      (_) {
        context.showSnack(widget.isEditing ? 'Actualizado' : 'Guardado');
        context.pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final category = ref.watch(categoryByIdProvider(_categoryId));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar movimiento' : 'Nuevo movimiento'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              _TypeToggle(value: _type, onChanged: _onTypeChanged),
              const SizedBox(height: AppSpacing.xl),
              TextFormField(
                controller: _amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Monto',
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
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Descripción'),
                textCapitalization: TextCapitalization.sentences,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Describe el movimiento';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              InkWell(
                onTap: _pickCategory,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    suffixIcon: Icon(Icons.chevron_right),
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
                        Text(category.name, style: context.text.titleSmall),
                      ] else
                        Text('Selecciona una categoría',
                            style: context.text.bodyMedium),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha',
                    suffixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(Formatters.date(_date)),
                ),
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
      ),
    );
  }
}

class _TypeToggle extends StatelessWidget {
  const _TypeToggle({required this.value, required this.onChanged});

  final TransactionType value;
  final ValueChanged<TransactionType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TypeChip(
            label: 'Gasto',
            icon: Icons.trending_down,
            color: AppColors.expense,
            selected: value.isExpense,
            onTap: () => onChanged(TransactionType.expense),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _TypeChip(
            label: 'Ingreso',
            icon: Icons.trending_up,
            color: AppColors.income,
            selected: value.isIncome,
            onTap: () => onChanged(TransactionType.income),
          ),
        ),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : Colors.transparent,
          border: Border.all(
            color: selected ? color : context.colors.outline,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? color : context.colors.outline),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: context.text.labelLarge?.copyWith(
                color: selected ? color : context.colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
