import 'package:hive/hive.dart';

/// Stores budget limits for a given month (current milestone only).
class Budget {
  Budget({
    required this.id,
    required this.year,
    required this.month,
    required this.categoryLimits,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });

  /// Composite id in the form `yyyy-mm` (UTC).
  final String id;
  final int year;
  final int month;
  final Map<String, int> categoryLimits;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;

  Budget copyWith({
    Map<String, int>? categoryLimits,
    DateTime? updatedAtUtc,
  }) {
    return Budget(
      id: id,
      year: year,
      month: month,
      categoryLimits: categoryLimits ?? this.categoryLimits,
      createdAtUtc: createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    );
  }

  static String idFor(int year, int month) =>
      '$year-${month.toString().padLeft(2, '0')}';

  factory Budget.empty(int year, int month) {
    final now = DateTime.now().toUtc();
    return Budget(
      id: idFor(year, month),
      year: year,
      month: month,
      categoryLimits: {},
      createdAtUtc: now,
      updatedAtUtc: now,
    );
  }
}

class BudgetAdapter extends TypeAdapter<Budget> {
  @override
  final int typeId = 2;

  @override
  Budget read(BinaryReader reader) {
    final id = reader.readString();
    final year = reader.readInt();
    final month = reader.readInt();
    final len = reader.readInt();
    final limits = <String, int>{};
    for (var i = 0; i < len; i++) {
      final key = reader.readString();
      final value = reader.readInt();
      limits[key] = value;
    }
    final createdAt = DateTime.fromMillisecondsSinceEpoch(
      reader.readInt(),
      isUtc: true,
    );
    final updatedAt = DateTime.fromMillisecondsSinceEpoch(
      reader.readInt(),
      isUtc: true,
    );
    return Budget(
      id: id,
      year: year,
      month: month,
      categoryLimits: limits,
      createdAtUtc: createdAt,
      updatedAtUtc: updatedAt,
    );
  }

  @override
  void write(BinaryWriter writer, Budget obj) {
    writer
      ..writeString(obj.id)
      ..writeInt(obj.year)
      ..writeInt(obj.month)
      ..writeInt(obj.categoryLimits.length);
    obj.categoryLimits.forEach((key, value) {
      writer
        ..writeString(key)
        ..writeInt(value);
    });
    writer
      ..writeInt(obj.createdAtUtc.millisecondsSinceEpoch)
      ..writeInt(obj.updatedAtUtc.millisecondsSinceEpoch);
  }
}
