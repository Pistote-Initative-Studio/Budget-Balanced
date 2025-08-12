import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../data/models/transaction.dart';
import '../../data/models/budget.dart';
import '../../data/repos/transaction_repo.dart';
import '../../data/repos/budget_repo.dart';
import '../../data/storage/hive_boxes.dart';

final hiveReadyProvider = FutureProvider<void>((ref) async {
  await initHive();
});

final transactionRepoProvider = Provider<TransactionRepo>((ref) {
  ref.watch(hiveReadyProvider);
  final box = Hive.box<BBTransaction>(Boxes.transactions);
  return TransactionRepo(box);
});

final transactionsProvider = StreamProvider<List<BBTransaction>>((ref) {
  final repo = ref.watch(transactionRepoProvider);
  return repo.watchAll();
});

final budgetRepoProvider = Provider<BudgetRepo>((ref) {
  ref.watch(hiveReadyProvider);
  final box = Hive.box<Budget>(Boxes.budgets);
  return BudgetRepo(box);
});

final currentMonthProvider = Provider<(int year, int month)>((ref) {
  final now = DateTime.now().toUtc();
  return (now.year, now.month);
});

final currentMonthBudgetProvider =
    StreamProvider<Budget>((ref) {
  final repo = ref.watch(budgetRepoProvider);
  final (year, month) = ref.watch(currentMonthProvider);
  return repo
      .watchForMonth(year, month)
      .map((b) => b ?? Budget.empty(year, month));
});

final categorySpendThisMonthProvider = Provider<Map<String, int>>((ref) {
  final txs = ref.watch(transactionsProvider).value ?? [];
  final (year, month) = ref.watch(currentMonthProvider);
  final start = DateTime.utc(year, month);
  final end = month == 12
      ? DateTime.utc(year + 1, 1)
      : DateTime.utc(year, month + 1);
  final map = <String, int>{};
  for (final tx in txs) {
    if (tx.dateUtc.isBefore(end) && !tx.dateUtc.isBefore(start)) {
      map[tx.category] = (map[tx.category] ?? 0) + tx.amountCents;
    }
  }
  return map;
});

class CategoryBudgetInfo {
  CategoryBudgetInfo({required this.limit, required this.spent});
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

  final Map<String, CategoryBudgetInfo> categories;
  final int totalLimit;
  final int totalSpent;
  int get totalRemaining => totalLimit - totalSpent;
  double get pctUsed =>
      totalLimit == 0 ? 0 : totalSpent / totalLimit * 100;
}

final budgetOverviewProvider = Provider<BudgetOverview>((ref) {
  final (year, month) = ref.watch(currentMonthProvider);
  final budget = ref.watch(currentMonthBudgetProvider).maybeWhen(
        data: (b) => b,
        orElse: () => Budget.empty(year, month),
      );
  final spend = ref.watch(categorySpendThisMonthProvider);
  final categories = {...budget.categoryLimits.keys, ...spend.keys};
  final perCat = <String, CategoryBudgetInfo>{};
  for (final c in categories) {
    final limit = budget.categoryLimits[c] ?? 0;
    final spent = spend[c] ?? 0;
    perCat[c] = CategoryBudgetInfo(limit: limit, spent: spent);
  }
  final totalLimit =
      perCat.values.fold<int>(0, (p, e) => p + e.limit);
  final totalSpent =
      perCat.values.fold<int>(0, (p, e) => p + e.spent);
  return BudgetOverview(
    categories: perCat,
    totalLimit: totalLimit,
    totalSpent: totalSpent,
  );
});

/// Existing provider retained for backward compatibility.
final monthSpendProvider = Provider<int>((ref) {
  ref.watch(transactionsProvider);
  final repo = ref.watch(transactionRepoProvider);
  return repo.totalSpentThisMonthCents(DateTime.now().toUtc());
});
