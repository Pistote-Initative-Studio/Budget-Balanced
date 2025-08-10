import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../models/budget.dart';
import '../storage/hive_boxes.dart';

final budgetRepoProvider = Provider((ref) => BudgetRepo());

class BudgetRepo {
  Box<Budget> get _box => Hive.box<Budget>(budgetsBox);

  Stream<List<Budget>> watchAll() {
    return _box.watch().map((_) => _box.values.toList());
  }

  Future<void> save(Budget budget) async {
    await _box.put(budget.id, budget);
  }

  Future<void> remove(String id) async {
    await _box.delete(id);
  }
}
