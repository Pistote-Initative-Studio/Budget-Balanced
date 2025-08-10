import 'package:hive/hive.dart';


@HiveType(typeId: 0)
class Transaction extends HiveObject {
  Transaction({
    required this.id,
    required this.amountCents,
    required this.dateUtc,
    this.merchant,
    this.category,
    this.paymentType,
    this.note,
    this.source,
    this.attachmentId,
  });

  @HiveField(0)
  String id;
  @HiveField(1)
  int amountCents;
  @HiveField(2)
  DateTime dateUtc;
  @HiveField(3)
  String? merchant;
  @HiveField(4)
  String? category;
  @HiveField(5)
  String? paymentType;
  @HiveField(6)
  String? note;
  @HiveField(7)
  String? source;
  @HiveField(8)
  String? attachmentId;
}
