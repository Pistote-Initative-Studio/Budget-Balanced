import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class Budget extends HiveObject {
  Budget({
    required this.id,
    required this.periodMonth,
    required this.periodYear,
    required this.categoryLimits,
    this.rolloverEnabled = false,
  });

  @HiveField(0)
  String id;
  @HiveField(1)
  int periodMonth;
  @HiveField(2)
  int periodYear;
  @HiveField(3)
  Map<String, int> categoryLimits;
  @HiveField(4)
  bool rolloverEnabled;
}
