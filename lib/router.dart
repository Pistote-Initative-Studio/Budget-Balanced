import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/dashboard/dashboard_page.dart';
import 'features/transactions/transactions_page.dart';
import 'features/budgets/budgets_page.dart';
import 'features/goals/goals_page.dart';
import 'features/settings/settings_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => _ScaffoldWithNav(child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const DashboardPage()),
          GoRoute(path: '/transactions', builder: (context, state) => const TransactionsPage()),
          GoRoute(path: '/budgets', builder: (context, state) => const BudgetsPage()),
          GoRoute(path: '/goals', builder: (context, state) => const GoalsPage()),
          GoRoute(path: '/settings', builder: (context, state) => const SettingsPage()),
        ],
      ),
    ],
  );
});

class _ScaffoldWithNav extends StatelessWidget {
  const _ScaffoldWithNav({required this.child});
  final Widget child;

  static int _locationToIndex(String location) {
    switch (location) {
      case '/':
        return 0;
      case '/transactions':
        return 1;
      case '/budgets':
        return 2;
      case '/goals':
        return 3;
      case '/settings':
        return 4;
      default:
        return 0;
    }
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/transactions');
        break;
      case 2:
        context.go('/budgets');
        break;
      case 3:
        context.go('/goals');
        break;
      case 4:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouter.of(context).location;
    final currentIndex = _locationToIndex(location);
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _onItemTapped(context, index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Transactions'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Budgets'),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Goals'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
