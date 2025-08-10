import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../models/goal.dart';
import '../storage/hive_boxes.dart';

final goalRepoProvider = Provider((ref) => GoalRepo());

class GoalRepo {
  Box<Goal> get _box => Hive.box<Goal>(goalsBox);

  Stream<List<Goal>> watchAll() {
    return _box.watch().map((_) => _box.values.toList());
  }

  Future<void> save(Goal goal) async {
    await _box.put(goal.id, goal);
  }

  Future<void> remove(String id) async {
    await _box.delete(id);
  }
}
