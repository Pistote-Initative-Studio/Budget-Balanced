import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'package:budget_balanced/app.dart';
import 'package:budget_balanced/data/models/transaction.dart';
import 'package:budget_balanced/data/storage/hive_adapters.dart';
import 'package:budget_balanced/data/storage/hive_boxes.dart';

void main() {
  setUp(() async {
    final dir = await Directory.systemTemp.createTemp();
    Hive.init(dir.path);
    registerHiveAdapters();
    await openHiveBoxes();
  });

  testWidgets('add transaction flow', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();

    // Navigate to transactions tab
    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();

    // Open add sheet
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '1');
    await tester.enterText(find.byType(TextField).last, 'Coffee');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Coffee'), findsOneWidget);
  });
}
