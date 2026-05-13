import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../transactions/domain/entities/transaction_type.dart';
import '../../domain/entities/category.dart';
import '../../domain/usecases/create_category.dart';
import '../providers/category_providers.dart';
import '../widgets/category_color_library.dart';
import '../widgets/category_icon_library.dart';

class CategoryFormPage extends ConsumerStatefulWidget {
  const CategoryFormPage({super.key, this.initial});

  final Category? initial;
  bool get isEditing => initial != null;

  @override
  ConsumerState<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends ConsumerState<CategoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late TransactionType _type;
  late String _iconKey;
  late String _colorKey;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _nameCtrl = TextEditingController(text: i?.name ?? '');
    _type = i?.type ?? TransactionType.expense;
    _iconKey = i?.iconKey ?? CategoryIconLibrary.all.first.key;
    _colorKey = i?.colorKey ?? CategoryColorLibrary.all.first.key;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final result = widget.isEditing
        ? await ref.read(updateCategoryProvider).call(
              widget.initial!.copyWith(
                name: _nameCtrl.text,
                iconKey: _iconKey,
                colorKey: _colorKey,
                type: _type,
              ),
            )
        : await ref.read(createCategoryProvider).call(
              CreateCategoryParams(
                id: const Uuid().v4(),
                name: _nameCtrl.text,
                iconKey: _iconKey,
                colorKey: _colorKey,
                type: _type,
              ),
            );

    if (!mounted) return;
    setState(() => _saving = false);
    result.fold(
      (f) => context.showSnack(f.message ?? 'Error al guardar'),
      (_) {
        context.showSnack(widget.isEditing ? 'Actualizada' : 'Guardada');
        Navigator.of(context).pop();
      },
    );
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar categoría'),
        content: const Text(
            'Las transacciones asociadas quedarán sin categoría.'),
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
        await ref.read(deleteCategoryProvider).call(widget.initial!.id);
    if (!mounted) return;
    result.fold(
      (f) => context.showSnack(f.message ?? 'Error al eliminar'),
      (_) {
        context.showSnack('Eliminada');
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.isEditing ? 'Editar categoría' : 'Nueva categoría'),
        actions: [
          if (widget.isEditing && !widget.initial!.isDefault)
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
            _TypeToggle(
              value: _type,
              onChanged: (v) => setState(() => _type = v),
            ),
            const SizedBox(height: AppSpacing.xl),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nombre'),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Nombre requerido';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Color', style: context.text.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: CategoryColorLibrary.all.map((entry) {
                final selected = entry.key == _colorKey;
                return GestureDetector(
                  onTap: () => setState(() => _colorKey = entry.key),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: entry.value,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected
                            ? context.colors.onSurface
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: selected
                        ? const Icon(Icons.check,
                            color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Ícono', style: context.text.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: CategoryIconLibrary.all.map((entry) {
                final selected = entry.key == _iconKey;
                final color = CategoryColorLibrary.get(_colorKey);
                return GestureDetector(
                  onTap: () => setState(() => _iconKey = entry.key),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: selected
                          ? color.withValues(alpha: 0.16)
                          : context.colors.surface,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(
                        color: selected ? color : context.colors.outline,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Icon(entry.value, color: color, size: 22),
                  ),
                );
              }).toList(),
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

class _TypeToggle extends StatelessWidget {
  const _TypeToggle({required this.value, required this.onChanged});

  final TransactionType value;
  final ValueChanged<TransactionType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Chip(
            label: 'Gasto',
            selected: value.isExpense,
            color: AppColors.expense,
            onTap: () => onChanged(TransactionType.expense),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _Chip(
            label: 'Ingreso',
            selected: value.isIncome,
            color: AppColors.income,
            onTap: () => onChanged(TransactionType.income),
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
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
        child: Center(
          child: Text(
            label,
            style: context.text.labelLarge?.copyWith(
              color: selected ? color : context.colors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
