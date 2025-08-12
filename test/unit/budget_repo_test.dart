import 'dart:io';

import 'package:budget_balanced/data/models/budget.dart';
import 'package:budget_balanced/data/repos/budget_repo.dart';
import 'package:budget_balanced/data/storage/hive_boxes.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Box<Budget> box;
  late BudgetRepo repo;

  setUp(() async {
    final dir = await Directory.systemTemp.createTemp();
    Hive.init(dir.path);
    Hive.registerAdapter(BudgetAdapter());
    box = await Hive.openBox<Budget>(Boxes.budgets);
    repo = BudgetRepo(box);
  });

  tearDown(() async {
    await box.deleteFromDisk();
  });

  test('create/update/watch', () async {
    final b1 = await repo.upsertForMonth(2023, 1, {'Food': 100});
    expect(b1.categoryLimits['Food'], 100);
    final fetched = repo.getForMonth(2023, 1);
    expect(fetched!.createdAtUtc, b1.createdAtUtc);
    await Future.delayed(const Duration(milliseconds: 10));
    await repo.updateLimits(2023, 1, {'Food': 200});
    final b2 = repo.getForMonth(2023, 1)!;
    expect(b2.categoryLimits['Food'], 200);
    expect(b2.createdAtUtc, b1.createdAtUtc);
    expect(b2.updatedAtUtc.isAfter(b1.updatedAtUtc), true);
    final watched = await repo.watchForMonth(2023, 1).last;
    expect(watched!.categoryLimits['Food'], 200);
  });
}
