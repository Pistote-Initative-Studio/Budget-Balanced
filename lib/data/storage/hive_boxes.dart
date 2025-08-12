import 'package:hive_flutter/hive_flutter.dart';

import '../models/transaction.dart';
import '../models/budget.dart';

class Boxes {
  Boxes._();
  static const transactions = 'bb_transactions';
  static const budgets = 'bb_budgets';
}

Future<void> initHive() async {
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(BBTransactionAdapter().typeId)) {
    Hive.registerAdapter(BBTransactionAdapter());
  }
  if (!Hive.isAdapterRegistered(BudgetAdapter().typeId)) {
    Hive.registerAdapter(BudgetAdapter());
  }
  await Hive.openBox<BBTransaction>(Boxes.transactions);
  await Hive.openBox<Budget>(Boxes.budgets);
}
