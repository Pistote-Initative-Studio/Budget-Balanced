import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../core/utils/currency.dart';
import '../../widgets/dashboard_header.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(savedThisMonthProvider);
    final remaining = ref.watch(remainingThisMonthProvider);
    final totalBudget = ref.watch(totalBudgetThisMonthProvider);
    final spent = ref.watch(totalSpentThisMonthProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DashboardHeader(
            savedCents: totalBudget == 0 ? 0 : saved,
            remainingCents: totalBudget == 0 ? 0 : remaining,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Budget This Month'),
                  const SizedBox(height: 8),
                  Text(formatCents(spent)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
