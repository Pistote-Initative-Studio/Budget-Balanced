import 'package:hive_flutter/hive_flutter.dart';

import '../models/transaction.dart';

class Boxes {
  Boxes._();
  static const transactions = 'bb_transactions';
}

Future<void> initHive() async {
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(BBTransactionAdapter().typeId)) {
    Hive.registerAdapter(BBTransactionAdapter());
  }
  await Hive.openBox<BBTransaction>(Boxes.transactions);
}
