import 'package:budget_balanced/core/di/providers.dart';
import 'package:budget_balanced/data/models/budget.dart';
import 'package:budget_balanced/data/models/transaction.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  test('aggregation and totals', () async {
    final txs = [
      BBTransaction(
        id: '1',
        amountCents: 500,
        dateUtc: DateTime.utc(2023, 1, 10),
        merchant: 'A',
        category: 'Food',
        paymentType: 'Card',
        note: '',
      ),
      BBTransaction(
        id: '2',
        amountCents: 100,
        dateUtc: DateTime.utc(2023, 1, 12),
        merchant: 'B',
        category: 'Transport',
        paymentType: 'Card',
        note: '',
      ),
      BBTransaction(
        id: '3',
        amountCents: 200,
        dateUtc: DateTime.utc(2023, 2, 1), // next month
        merchant: 'C',
        category: 'Food',
        paymentType: 'Card',
        note: '',
      ),
    ];
    final now = DateTime.utc(2023, 1, 1);
    final budget = Budget(
      id: Budget.idFor(2023, 1),
      year: 2023,
      month: 1,
      categoryLimits: {'Food': 400, 'Transport': 300},
      createdAtUtc: now,
      updatedAtUtc: now,
    );
    final container = ProviderContainer(overrides: [
      currentMonthProvider.overrideWithValue((2023, 1)),
      transactionsProvider.overrideWith((ref) => Stream.value(txs)),
      currentMonthBudgetProvider.overrideWith((ref) => Stream.value(budget)),
    ]);

    final spend = container.read(categorySpendThisMonthProvider);
    expect(spend['Food'], 500);
    expect(spend['Transport'], 100);
    expect(spend.containsKey('Other'), false);

    final overview = container.read(budgetOverviewProvider);
    final food = overview.categories['Food']!;
    expect(food.limit, 400);
    expect(food.spent, 500);
    expect(food.remaining, -100);
    expect(overview.totalLimit, 700);
    expect(overview.totalSpent, 600);
    expect(overview.totalRemaining, 100);
    expect(overview.pctUsed, closeTo(600 / 700 * 100, 0.001));
  });

  test('zero budget totals', () {
    final container = ProviderContainer(overrides: [
      currentMonthProvider.overrideWithValue((2023, 1)),
      transactionsProvider.overrideWith((ref) => const Stream.empty()),
      currentMonthBudgetProvider.overrideWith(
          (ref) => Stream.value(Budget.empty(2023, 1))),
    ]);
    final overview = container.read(budgetOverviewProvider);
    expect(overview.totalLimit, 0);
    expect(overview.pctUsed, 0);
  });
}
