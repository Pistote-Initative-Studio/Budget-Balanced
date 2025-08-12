import 'package:hive/hive.dart';

import '../models/budget.dart';

class BudgetRepo {
  BudgetRepo(this._box);
  final Box<Budget> _box;

  String _id(int year, int month) => Budget.idFor(year, month);

  Budget? getForMonth(int year, int month) => _box.get(_id(year, month));

  Stream<Budget?> watchForMonth(int year, int month) async* {
    final id = _id(year, month);
    yield _box.get(id);
    yield* _box.watch(key: id).map((event) => event.value as Budget?);
  }

  Future<Budget> upsertForMonth(
      int year, int month, Map<String, int> limits) async {
    final id = _id(year, month);
    final existing = _box.get(id);
    final now = DateTime.now().toUtc();
    final budget = Budget(
      id: id,
      year: year,
      month: month,
      categoryLimits: Map.from(limits),
      createdAtUtc: existing?.createdAtUtc ?? now,
      updatedAtUtc: now,
    );
    await _box.put(id, budget);
    return budget;
  }

  Future<void> updateLimits(
      int year, int month, Map<String, int> limits) async {
    await upsertForMonth(year, month, limits);
  }
}
