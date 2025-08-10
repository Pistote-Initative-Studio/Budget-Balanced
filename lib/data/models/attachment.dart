import 'package:hive/hive.dart';

@HiveType(typeId: 3)
class Attachment extends HiveObject {
  Attachment({
    required this.id,
    required this.imagePath,
    this.ocrJson,
  });

  @HiveField(0)
  String id;
  @HiveField(1)
  String imagePath;
  @HiveField(2)
  String? ocrJson;
}
