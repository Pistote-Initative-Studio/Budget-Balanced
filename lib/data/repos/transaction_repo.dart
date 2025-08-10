import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../models/transaction.dart';
import '../storage/hive_boxes.dart';

final transactionRepoProvider = Provider((ref) => TransactionRepo());

class TransactionRepo {
  Box<Transaction> get _box => Hive.box<Transaction>(transactionsBox);

  Stream<List<Transaction>> watchAll() {
    return _box.watch().map((_) => _box.values.toList());
  }

  Future<void> add(Transaction tx) async {
    await _box.put(tx.id, tx);
  }

  Future<void> update(Transaction tx) async {
    await _box.put(tx.id, tx);
  }

  Future<void> remove(String id) async {
    await _box.delete(id);
  }
}
