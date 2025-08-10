import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:budget_balanced/data/models/transaction.dart';
import 'package:budget_balanced/data/storage/hive_adapters.dart';
import 'package:budget_balanced/data/storage/hive_boxes.dart';
import 'package:budget_balanced/data/repos/transaction_repo.dart';

void main() {
  setUp(() async {
    final dir = await Directory.systemTemp.createTemp();
    Hive.init(dir.path);
    registerHiveAdapters();
    await Hive.openBox<Transaction>(transactionsBox);
  });

  tearDown(() async {
    await Hive.deleteBoxFromDisk(transactionsBox);
  });

  test('CRUD operations', () async {
    final repo = TransactionRepo();
    final tx = Transaction(
      id: '1',
      amountCents: 100,
      dateUtc: DateTime.utc(2023, 1, 1),
      merchant: 'Test',
    );
    await repo.add(tx);
    expect((await repo.watchAll().first).length, 1);
    await repo.remove('1');
    expect((await repo.watchAll().first).length, 0);
  });
}
