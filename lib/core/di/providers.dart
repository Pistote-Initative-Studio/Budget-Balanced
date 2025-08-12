import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../data/models/budget.dart';
import '../../data/models/transaction.dart';
import '../../data/repos/budget_repo.dart';
import '../../data/repos/transaction_repo.dart';
import '../../data/storage/hive_boxes.dart';

/// Provides the current UTC month `(year, month)`.
final currentMonthProvider = Provider<(int, int)>((ref) {
  final now = DateTime.now().toUtc();
  return (now.year, now.month);
});

/// Repositories
final transactionRepoProvider = Provider<TransactionRepo>((ref) {
  final box = Hive.box<BBTransaction>(Boxes.transactions);
  return TransactionRepo(box);
});

final budgetRepoProvider = Provider<BudgetRepo>((ref) {
  final box = Hive.box<Budget>(Boxes.budgets);
  return BudgetRepo(box);
});

/// Streams
final transactionsProvider =
    StreamProvider<List<BBTransaction>>((ref) {
  final repo = ref.watch(transactionRepoProvider);
  return repo.watchAll();
});

final currentMonthBudgetProvider =
    StreamProvider<Budget>((ref) {
  final repo = ref.watch(budgetRepoProvider);
  final (year, month) = ref.watch(currentMonthProvider);
  return repo
      .watchForMonth(year, month)
      .map((b) => b ?? Budget.empty(year, month));
});

/// Spend totals
final totalSpentThisMonthProvider = Provider<int>((ref) {
  final txs = ref
      .watch(transactionsProvider)
      .maybeWhen(data: (v) => v, orElse: () => const <BBTransaction>[]);
  final now = DateTime.now().toUtc();
  final start = DateTime.utc(now.year, now.month, 1);
  final end = DateTime.utc(now.year, now.month + 1, 1);
  return txs
      .where((t) =>
          t.dateUtc.isAfter(start.subtract(const Duration(milliseconds: 1))) &&
          t.dateUtc.isBefore(end))
      .fold<int>(0, (sum, t) => sum + t.amountCents);
});

/// Category spend map
final categorySpendThisMonthProvider = Provider<Map<String, int>>((ref) {
  final txs = ref
      .watch(transactionsProvider)
      .maybeWhen(data: (v) => v, orElse: () => const <BBTransaction>[]);
  final now = DateTime.now().toUtc();
  final start = DateTime.utc(now.year, now.month, 1);
  final end = DateTime.utc(now.year, now.month + 1, 1);

  final map = <String, int>{};
  for (final tx in txs) {
    final d = tx.dateUtc;
    if (d.isAfter(start.subtract(const Duration(milliseconds: 1))) &&
        d.isBefore(end)) {
      map.update(tx.category, (v) => v + tx.amountCents,
          ifAbsent: () => tx.amountCents);
    }
  }
  return map;
});

/// Models for budget overview
class BudgetCategoryOverview {
  BudgetCategoryOverview({required this.limit, required this.spent});
  final int limit;
  final int spent;
  int get remaining => limit - spent;
}

class BudgetOverview {
  BudgetOverview({
    required this.categories,
    required this.totalLimit,
    required this.totalSpent,
  });
  final Map<String, BudgetCategoryOverview> categories;
  final int totalLimit;
  final int totalSpent;
  int get totalRemaining => totalLimit - totalSpent;
  double get pctUsed => totalLimit == 0 ? 0 : totalSpent / totalLimit * 100;
}

/// Aggregate current month budget and spend information.
final budgetOverviewProvider = Provider<BudgetOverview>((ref) {
  final budget = ref.watch(currentMonthBudgetProvider).asData?.value;
  final spend = ref.watch(categorySpendThisMonthProvider);
  final categories = <String, BudgetCategoryOverview>{};
  final limits = budget?.categoryLimits ?? const {};
  final allCats = {...limits.keys, ...spend.keys};
  for (final c in allCats) {
    final limit = limits[c] ?? 0;
    final spent = spend[c] ?? 0;
    categories[c] = BudgetCategoryOverview(limit: limit, spent: spent);
  }
  final totalLimit = limits.values.fold<int>(0, (s, v) => s + v);
  final totalSpent = spend.values.fold<int>(0, (s, v) => s + v);
  return BudgetOverview(
    categories: categories,
    totalLimit: totalLimit,
    totalSpent: totalSpent,
  );
});

/// Totals for dashboard header
final totalBudgetThisMonthProvider = Provider<int>((ref) {
  final b = ref
      .watch(currentMonthBudgetProvider)
      .maybeWhen(data: (v) => v, orElse: () => null);
  if (b == null) return 0;
  return b.categoryLimits.values.fold<int>(0, (sum, v) => sum + v);
});

final remainingThisMonthProvider = Provider<int>((ref) {
  final budget = ref.watch(totalBudgetThisMonthProvider);
  final spent = ref.watch(totalSpentThisMonthProvider);
  return budget - spent;
});

final savedThisMonthProvider = Provider<int>((ref) {
  final remaining = ref.watch(remainingThisMonthProvider);
  return remaining > 0 ? remaining : 0;
});

// Backwards compatibility
@Deprecated('Use totalSpentThisMonthProvider')
final monthSpendProvider = totalSpentThisMonthProvider;
