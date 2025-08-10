import 'package:hive/hive.dart';

@HiveType(typeId: 2)
class Goal extends HiveObject {
  Goal({
    required this.id,
    required this.name,
    required this.targetCents,
    this.targetDateUtc,
    this.savedCents = 0,
  });

  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  int targetCents;
  @HiveField(3)
  DateTime? targetDateUtc;
  @HiveField(4)
  int savedCents;
}
