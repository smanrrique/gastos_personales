import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/budgets/presentation/pages/budget_form_page.dart';
import '../../features/budgets/presentation/pages/budgets_page.dart';
import '../../features/categories/presentation/pages/categories_page.dart';
import '../../features/categories/presentation/pages/category_form_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_shell.dart';
import '../../features/dashboard/presentation/pages/home_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/statistics/presentation/pages/statistics_page.dart';
import '../../features/transactions/presentation/pages/transaction_detail_page.dart';
import '../../features/transactions/presentation/pages/transaction_form_page.dart';
import '../../features/transactions/presentation/pages/transactions_page.dart';
import 'app_routes.dart';

final _rootNav = GlobalKey<NavigatorState>();
final _homeNav = GlobalKey<NavigatorState>();
final _txsNav = GlobalKey<NavigatorState>();
final _statsNav = GlobalKey<NavigatorState>();
final _budgetsNav = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNav,
    initialLocation: AppRoutes.dashboard,
    debugLogDiagnostics: true,
    routes: [
      // Rutas fuera del shell (full-screen)
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const _Placeholder(title: 'Login'),
      ),
      GoRoute(
        path: AppRoutes.categories,
        builder: (context, state) => const CategoriesPage(),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) => const CategoryFormPage(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsPage(),
      ),

      // Shell con BottomNavigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => DashboardShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _homeNav,
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _txsNav,
            routes: [
              GoRoute(
                path: AppRoutes.transactions,
                builder: (context, state) => const TransactionsPage(),
                routes: [
                  GoRoute(
                    path: 'new',
                    parentNavigatorKey: _rootNav,
                    builder: (context, state) => const TransactionFormPage(),
                  ),
                  GoRoute(
                    path: ':id',
                    parentNavigatorKey: _rootNav,
                    builder: (context, state) =>
                        TransactionDetailPage(id: state.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _statsNav,
            routes: [
              GoRoute(
                path: AppRoutes.statistics,
                builder: (context, state) => const StatisticsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _budgetsNav,
            routes: [
              GoRoute(
                path: AppRoutes.budgets,
                builder: (context, state) => const BudgetsPage(),
                routes: [
                  GoRoute(
                    path: 'new',
                    parentNavigatorKey: _rootNav,
                    builder: (context, state) => const BudgetFormPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Ruta no encontrada: ${state.uri}')),
    ),
  );
});

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}
