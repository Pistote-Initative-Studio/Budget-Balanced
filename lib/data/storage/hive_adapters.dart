import 'package:hive/hive.dart';

import '../models/transaction.dart';
import '../models/budget.dart';
import '../models/goal.dart';
import '../models/attachment.dart';

void registerHiveAdapters() {
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(BudgetAdapter());
  Hive.registerAdapter(GoalAdapter());
  Hive.registerAdapter(AttachmentAdapter());
}

class TransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final int typeId = 0;

  @override
  Transaction read(BinaryReader reader) {
    String? _nullify(String value) => value.isEmpty ? null : value;
    return Transaction(
      id: reader.readString(),
      amountCents: reader.readInt(),
      dateUtc: DateTime.parse(reader.readString()),
      merchant: _nullify(reader.readString()),
      category: _nullify(reader.readString()),
      paymentType: _nullify(reader.readString()),
      note: _nullify(reader.readString()),
      source: _nullify(reader.readString()),
      attachmentId: _nullify(reader.readString()),
    );
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer
      ..writeString(obj.id)
      ..writeInt(obj.amountCents)
      ..writeString(obj.dateUtc.toIso8601String())
      ..writeString(obj.merchant ?? '')
      ..writeString(obj.category ?? '')
      ..writeString(obj.paymentType ?? '')
      ..writeString(obj.note ?? '')
      ..writeString(obj.source ?? '')
      ..writeString(obj.attachmentId ?? '');
  }
}

class BudgetAdapter extends TypeAdapter<Budget> {
  @override
  final int typeId = 1;

  @override
  Budget read(BinaryReader reader) {
    final id = reader.readString();
    final month = reader.readInt();
    final year = reader.readInt();
    final limits = Map<String, int>.from(reader.readMap());
    final rollover = reader.readBool();
    return Budget(
      id: id,
      periodMonth: month,
      periodYear: year,
      categoryLimits: limits,
      rolloverEnabled: rollover,
    );
  }

  @override
  void write(BinaryWriter writer, Budget obj) {
    writer
      ..writeString(obj.id)
      ..writeInt(obj.periodMonth)
      ..writeInt(obj.periodYear)
      ..writeMap(obj.categoryLimits)
      ..writeBool(obj.rolloverEnabled);
  }
}

class GoalAdapter extends TypeAdapter<Goal> {
  @override
  final int typeId = 2;

  @override
  Goal read(BinaryReader reader) {
    return Goal(
      id: reader.readString(),
      name: reader.readString(),
      targetCents: reader.readInt(),
      targetDateUtc: reader.readBool() ? DateTime.parse(reader.readString()) : null,
      savedCents: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, Goal obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.name)
      ..writeInt(obj.targetCents)
      ..writeBool(obj.targetDateUtc != null)
      ..writeString(obj.targetDateUtc?.toIso8601String() ?? '')
      ..writeInt(obj.savedCents);
  }
}

class AttachmentAdapter extends TypeAdapter<Attachment> {
  @override
  final int typeId = 3;

  @override
  Attachment read(BinaryReader reader) {
    return Attachment(
      id: reader.readString(),
      imagePath: reader.readString(),
      ocrJson: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Attachment obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.imagePath)
      ..writeString(obj.ocrJson ?? '');
  }
}
