import 'package:flutter/material.dart';

class BudgetsPage extends StatelessWidget {
  const BudgetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppBar(title: Text('Budgets')),
      body: Center(child: Text('No budgets yet')),
    );
  }
}
