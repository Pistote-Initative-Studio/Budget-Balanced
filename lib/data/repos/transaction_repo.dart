import 'package:hive/hive.dart';

import '../models/transaction.dart';
import '../storage/hive_boxes.dart';

class TransactionRepo {
  TransactionRepo(this._box);
  final Box<BBTransaction> _box;

  Stream<List<BBTransaction>> watchAll() async* {
    yield _sorted(_box.values.toList());
    yield* _box.watch().map((_) => _sorted(_box.values.toList()));
  }

  Future<void> add(BBTransaction tx) => _box.put(tx.id, tx);

  Future<void> update(BBTransaction tx) => _box.put(tx.id, tx);

  Future<void> remove(String id) => _box.delete(id);

  List<BBTransaction> _sorted(List<BBTransaction> items) {
    items.sort((a, b) => b.dateUtc.compareTo(a.dateUtc));
    return items;
  }

  int totalSpentThisMonthCents(DateTime nowUtc) {
    final monthStart = DateTime.utc(nowUtc.year, nowUtc.month);
    final nextMonthStart = DateTime.utc(nowUtc.year, nowUtc.month + 1);
    return _box.values
        .where((tx) =>
            tx.dateUtc.isAtSameMomentAs(monthStart) ||
            (tx.dateUtc.isAfter(monthStart) && tx.dateUtc.isBefore(nextMonthStart)))
        .fold(0, (sum, tx) => sum + tx.amountCents);
  }
}
