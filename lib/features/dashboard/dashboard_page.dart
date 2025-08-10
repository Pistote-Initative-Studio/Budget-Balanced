import 'package:flutter/material.dart';

import '../../widgets/chart_spend_vs_budget.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text('This Month Spend'),
          SizedBox(height: 16),
          ChartSpendVsBudget(),
        ],
      ),
    );
  }
}
