import 'dart:io';

import 'package:budget_balanced/app.dart';
import 'package:budget_balanced/core/di/providers.dart';
import 'package:budget_balanced/core/utils/currency.dart';
import 'package:budget_balanced/data/models/budget.dart';
import 'package:budget_balanced/data/models/transaction.dart';
import 'package:budget_balanced/data/repos/transaction_repo.dart';
import 'package:budget_balanced/data/storage/hive_boxes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late List<Override> overrides;

  setUp(() async {
    final dir = await Directory.systemTemp.createTemp();
    Hive.init(dir.path);
    Hive.registerAdapter(BBTransactionAdapter());
    Hive.registerAdapter(BudgetAdapter());
    await Hive.openBox<BBTransaction>(Boxes.transactions);
    await Hive.openBox<Budget>(Boxes.budgets);
    overrides = [
      hiveReadyProvider.overrideWith((ref) async {}),
    ];
  });

  tearDown(() async {
    await Hive.deleteBoxFromDisk(Boxes.transactions);
    await Hive.deleteBoxFromDisk(Boxes.budgets);
  });

  testWidgets('edit limits and reflect in UI', (tester) async {
    await tester.pumpWidget(ProviderScope(overrides: overrides, child: const App()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Budgets'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('limit_Food')), '100');
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(
      find.text('Spent ${formatCents(0)} • Remaining ${formatCents(10000)}'),
      findsOneWidget,
    );

    final repo = TransactionRepo(Hive.box<BBTransaction>(Boxes.transactions));
    await repo.add(BBTransaction(
      id: '1',
      amountCents: 5000,
      dateUtc: DateTime.now().toUtc(),
      merchant: 'Shop',
      category: 'Food',
      paymentType: 'Card',
      note: '',
    ));
    await tester.pumpAndSettle();

    expect(
      find.text('Spent ${formatCents(5000)} • Remaining ${formatCents(5000)}'),
      findsOneWidget,
    );

    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();
    expect(
      find.text(
          '${formatCents(5000)} / ${formatCents(10000)} • 50%'),
      findsOneWidget,
    );
  });
}
