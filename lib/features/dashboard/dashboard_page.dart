import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../core/utils/currency.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(budgetOverviewProvider);
    final totalLimit = overview.totalLimit;
    final totalSpent = overview.totalSpent;
    final pct = overview.pctUsed;
    final double progress = totalLimit == 0
        ? 0.0
        : (totalSpent / totalLimit).clamp(0.0, 1.0).toDouble();
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Budget This Month'),
                  const SizedBox(height: 8),
                  if (totalLimit == 0)
                    const Text('No budget set')
                  else ...[
                    Text(
                        '${formatCents(totalSpent)} / ${formatCents(totalLimit)} • ${pct.toStringAsFixed(0)}%'),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(value: progress),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
