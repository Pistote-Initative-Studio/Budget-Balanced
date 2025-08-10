import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/transaction.dart';
import '../../data/repos/transaction_repo.dart';
import '../../data/repos/budget_repo.dart';
import '../../data/repos/goal_repo.dart';

final transactionsProvider = StreamProvider<List<Transaction>>((ref) {
  final repo = ref.watch(transactionRepoProvider);
  return repo.watchAll();
});

final budgetsRepoProvider = budgetRepoProvider;
final goalsRepoProvider = goalRepoProvider;
