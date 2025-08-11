import 'dart:io';

import 'package:budget_balanced/app.dart';
import 'package:budget_balanced/core/di/providers.dart';
import 'package:budget_balanced/data/models/transaction.dart';
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
    await Hive.openBox<BBTransaction>(Boxes.transactions);
    overrides = [
      hiveReadyProvider.overrideWith((ref) async {}),
    ];
  });

  tearDown(() async {
    await Hive.deleteBoxFromDisk(Boxes.transactions);
  });

  testWidgets('add transaction flow', (tester) async {
    await tester.pumpWidget(ProviderScope(overrides: overrides, child: const App()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('amount')), '1');
    await tester.enterText(find.byKey(const Key('merchant')), 'Coffee');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Coffee'), findsOneWidget);
  });
}
