import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/di/providers.dart';
import '../../core/utils/currency.dart';

class BudgetsPage extends ConsumerStatefulWidget {
  const BudgetsPage({super.key});

  @override
  ConsumerState<BudgetsPage> createState() => _BudgetsPageState();
}

class _BudgetsPageState extends ConsumerState<BudgetsPage> {
  final Map<String, TextEditingController> _controllers = {};
  static const _defaultCats = [
    'General',
    'Food',
    'Transport',
    'Bills',
    'Shopping',
  ];

  void _syncControllers(Map<String, int> limits) {
    final categories = {..._defaultCats, ...limits.keys};
    for (final c in categories) {
      final txt = limits[c] != null && limits[c]! > 0
          ? (limits[c]! / 100).toString()
          : '';
      if (_controllers.containsKey(c)) {
        if (_controllers[c]!.text != txt) {
          _controllers[c]!.text = txt;
        }
      } else {
        _controllers[c] = TextEditingController(text: txt);
      }
    }
  }

  void _apply(int year, int month, List<String> categories) {
    final limits = <String, int>{};
    for (final c in categories) {
      final parsed = parseCurrency(_controllers[c]!.text) ?? 0;
      limits[c] = parsed < 0 ? 0 : parsed;
    }
    ref.read(budgetRepoProvider).updateLimits(year, month, limits);
  }

  @override
  Widget build(BuildContext context) {
    final (year, month) = ref.watch(currentMonthProvider);
    final budgetAsync = ref.watch(currentMonthBudgetProvider);
    final spend = ref.watch(categorySpendThisMonthProvider);
    return budgetAsync.when(
      data: (budget) {
        _syncControllers(budget.categoryLimits);
        final categories = {
          ..._defaultCats,
          ...budget.categoryLimits.keys,
          ...spend.keys
        }.toList()
          ..sort();
        final monthLabel = DateFormat('MMMM yyyy')
            .format(DateTime.utc(year, month));
        return Scaffold(
          appBar: AppBar(title: const Text('Budgets')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(monthLabel, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              for (final c in categories)
                _CategoryRow(
                  category: c,
                  controller: _controllers[c]!,
                  spent: spend[c] ?? 0,
                  limit: budget.categoryLimits[c] ?? 0,
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _apply(year, month, categories),
                child: const Text('Apply'),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.controller,
    required this.spent,
    required this.limit,
  });

  final String category;
  final TextEditingController controller;
  final int spent;
  final int limit;

  @override
  Widget build(BuildContext context) {
    final remaining = limit - spent;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category),
                const SizedBox(height: 4),
                Text(
                  'Spent ${formatCents(spent)} • Remaining ${formatCents(remaining)}',
                ),
              ],
            ),
          ),
          SizedBox(
            width: 100,
            child: TextField(
              key: Key('limit_$category'),
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: '0'),
            ),
          ),
        ],
      ),
    );
  }
}
