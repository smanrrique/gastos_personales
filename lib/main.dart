import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/config/env_config.dart';
import 'core/constants/app_constants.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/services/hive_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/notifications/presentation/providers/budget_alert_observer.dart';
import 'features/settings/presentation/providers/settings_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await EnvConfig.load();
  await initializeDateFormatting(AppConstants.defaultLocale);
  await HiveService.init();
  await NotificationService.init();
  await configureDependencies();

  runApp(const ProviderScope(child: GastosPersonalesApp()));
}

class GastosPersonalesApp extends ConsumerWidget {
  const GastosPersonalesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final settings = ref.watch(settingsControllerProvider);

    // Activa el observador de presupuestos: dispara alertas locales
    // cuando un presupuesto supera su umbral o se excede.
    ref.watch(budgetAlertObserverProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode,
      routerConfig: router,
      builder: (context, child) {
        const double maxMobileWidth = 480;
        final data = MediaQuery.of(context);
        final constrainedWidth = data.size.width > maxMobileWidth
            ? maxMobileWidth
            : data.size.width;
        return ColoredBox(
          color: const Color(0xFF1A1A2E),
          child: Center(
            child: SizedBox(
              width: constrainedWidth,
              child: MediaQuery(
                data: data.copyWith(
                  size: Size(constrainedWidth, data.size.height),
                ),
                child: child!,
              ),
            ),
          ),
        );
      },
    );
  }
}
