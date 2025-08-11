import 'dart:io';

import 'package:budget_balanced/data/models/transaction.dart';
import 'package:budget_balanced/data/repos/transaction_repo.dart';
import 'package:budget_balanced/data/storage/hive_boxes.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Box<BBTransaction> box;
  late TransactionRepo repo;

  setUp(() async {
    final dir = await Directory.systemTemp.createTemp();
    Hive.init(dir.path);
    Hive.registerAdapter(BBTransactionAdapter());
    box = await Hive.openBox<BBTransaction>(Boxes.transactions);
    repo = TransactionRepo(box);
  });

  tearDown(() async {
    await box.deleteFromDisk();
  });

  test('CRUD operations', () async {
    final tx = BBTransaction(
      id: '1',
      amountCents: 100,
      dateUtc: DateTime.utc(2023, 1, 1),
      merchant: 'Test',
      category: 'General',
      paymentType: 'Card',
      note: '',
    );
    await repo.add(tx);
    expect((await repo.watchAll().first).length, 1);
    expect(repo.totalSpentThisMonthCents(DateTime.utc(2023, 1, 15)), 100);
    await repo.remove('1');
    expect((await repo.watchAll().first).isEmpty, true);
  });
}
