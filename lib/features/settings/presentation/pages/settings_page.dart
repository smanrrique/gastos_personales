import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/settings_providers.dart';
import '../widgets/export_service.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final ctrl = ref.read(settingsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        children: [
          _Section(title: 'Apariencia'),
          _ThemeTile(current: settings.themeMode, onChanged: ctrl.setThemeMode),
          const Divider(height: 1),
          _Section(title: 'Idioma y moneda'),
          _CurrencyTile(
            current: settings.currencyCode,
            onChanged: ctrl.setCurrency,
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Idioma'),
            subtitle: Text(settings.locale),
            onTap: () => _showLocaleSheet(context, ctrl, settings.locale),
          ),
          const Divider(height: 1),
          _Section(title: 'Datos'),
          ListTile(
            leading: const Icon(Icons.upload_file_outlined),
            title: const Text('Exportar datos'),
            subtitle: const Text('Genera un archivo JSON con tus transacciones, categorías y presupuestos.'),
            onTap: () => _export(context),
          ),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Importar datos'),
            subtitle: const Text('Pega el contenido JSON exportado previamente.'),
            onTap: () => _showImportDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.delete_sweep_outlined,
                color: Color(0xFFEF4444)),
            title: const Text('Borrar todos los datos'),
            subtitle: const Text(
                'Elimina transacciones, categorías y presupuestos locales.'),
            onTap: () => _confirmClear(context),
          ),
          const Divider(height: 1),
          _Section(title: 'Acerca de'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Versión'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.business_outlined),
            title: const Text(AppConstants.appName),
            subtitle: const Text('Finanzas personales 100% local.'),
          ),
          const SizedBox(height: AppSpacing.huge),
        ],
      ),
    );
  }

  Future<void> _export(BuildContext context) async {
    try {
      final file = await ExportService.exportAllToJson();
      if (!context.mounted) return;
      showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Exportación completada'),
          content: SelectableText(
            file.path,
            style: context.text.bodySmall,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      context.showSnack('Error al exportar: $e');
    }
  }

  Future<void> _showImportDialog(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Importar datos'),
        content: SizedBox(
          width: 480,
          child: TextField(
            controller: controller,
            maxLines: 10,
            decoration: const InputDecoration(
              hintText: 'Pega aquí el JSON exportado…',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Importar'),
          ),
        ],
      ),
    );
    if (result != true || !context.mounted) return;
    try {
      final summary = await ExportService.importFromJson(controller.text);
      if (!context.mounted) return;
      context.showSnack(
        'Importadas ${summary.txs} transacciones, '
        '${summary.cats} categorías y ${summary.budgets} presupuestos.',
      );
    } catch (e) {
      if (!context.mounted) return;
      context.showSnack('JSON inválido: $e');
    }
  }

  Future<void> _confirmClear(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Borrar todos los datos'),
        content: const Text(
            'Esta acción no se puede deshacer. Las categorías por defecto se re-crearán al reiniciar la app.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await ExportService.clearAll();
    if (!context.mounted) return;
    context.showSnack('Datos borrados.');
  }

  Future<void> _showLocaleSheet(
      BuildContext context, SettingsController ctrl, String current) async {
    final options = const [
      ('es_CO', 'Español (Colombia)'),
      ('es_MX', 'Español (México)'),
      ('es_ES', 'Español (España)'),
      ('en_US', 'English (US)'),
    ];
    await showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: RadioGroup<String>(
          groupValue: current,
          onChanged: (v) {
            if (v != null) {
              ctrl.setLocale(v);
              Navigator.of(context).pop();
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: options
                .map((o) => RadioListTile<String>(
                      value: o.$1,
                      title: Text(o.$2),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Text(
        title.toUpperCase(),
        style: context.text.labelSmall?.copyWith(letterSpacing: 0.6),
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({required this.current, required this.onChanged});
  final ThemeMode current;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.brightness_6_outlined),
      title: const Text('Tema'),
      subtitle: Text(switch (current) {
        ThemeMode.system => 'Automático',
        ThemeMode.light => 'Claro',
        ThemeMode.dark => 'Oscuro',
      }),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        builder: (_) => SafeArea(
          child: RadioGroup<ThemeMode>(
            groupValue: current,
            onChanged: (v) {
              if (v != null) {
                onChanged(v);
                Navigator.of(context).pop();
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: ThemeMode.values
                  .map((m) => RadioListTile<ThemeMode>(
                        value: m,
                        title: Text(switch (m) {
                          ThemeMode.system => 'Automático',
                          ThemeMode.light => 'Claro',
                          ThemeMode.dark => 'Oscuro',
                        }),
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _CurrencyTile extends StatelessWidget {
  const _CurrencyTile({required this.current, required this.onChanged});
  final String current;
  final ValueChanged<String> onChanged;

  static const _currencies = ['COP', 'USD', 'EUR', 'MXN', 'ARS', 'CLP', 'PEN'];

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.attach_money),
      title: const Text('Moneda'),
      subtitle: Text(current),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        builder: (_) => SafeArea(
          child: RadioGroup<String>(
            groupValue: current,
            onChanged: (v) {
              if (v != null) {
                onChanged(v);
                Navigator.of(context).pop();
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _currencies
                  .map((c) => RadioListTile<String>(
                        value: c,
                        title: Text(c),
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}
