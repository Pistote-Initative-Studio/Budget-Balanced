import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../data/models/transaction.dart';
import '../../data/repos/transaction_repo.dart';
import '../../data/storage/hive_boxes.dart';

final transactionRepoProvider = Provider<TransactionRepo>((ref) {
  final box = Hive.box<BBTransaction>(Boxes.transactions);
  return TransactionRepo(box);
});

final transactionsProvider =
    StreamProvider<List<BBTransaction>>((ref) {
  final repo = ref.watch(transactionRepoProvider);
  return repo.watchAll();
});

final monthSpendProvider = Provider<int>((ref) {
  ref.watch(transactionsProvider);
  final repo = ref.watch(transactionRepoProvider);
  return repo.totalSpentThisMonthCents(DateTime.now().toUtc());
});
