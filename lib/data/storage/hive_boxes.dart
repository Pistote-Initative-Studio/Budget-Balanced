import 'package:hive/hive.dart';

import '../models/transaction.dart';
import '../models/budget.dart';
import '../models/goal.dart';
import '../models/attachment.dart';

const transactionsBox = 'transactions';
const budgetsBox = 'budgets';
const goalsBox = 'goals';
const attachmentsBox = 'attachments';

Future<void> openHiveBoxes() async {
  await Hive.openBox<Transaction>(transactionsBox);
  await Hive.openBox<Budget>(budgetsBox);
  await Hive.openBox<Goal>(goalsBox);
  await Hive.openBox<Attachment>(attachmentsBox);
}
