import 'package:hive/hive.dart';

/// Represents a manual transaction within the app.
class BBTransaction {
  BBTransaction({
    required this.id,
    required this.amountCents,
    required this.dateUtc,
    required this.merchant,
    required this.category,
    required this.paymentType,
    required this.note,
  });

  final String id;
  final int amountCents;
  final DateTime dateUtc;
  final String merchant;
  final String category;
  final String paymentType;
  final String note;
}

class BBTransactionAdapter extends TypeAdapter<BBTransaction> {
  @override
  final int typeId = 1;

  @override
  BBTransaction read(BinaryReader reader) {
    return BBTransaction(
      id: reader.readString(),
      amountCents: reader.readInt(),
      dateUtc: DateTime.fromMillisecondsSinceEpoch(
        reader.readInt(),
        isUtc: true,
      ),
      merchant: reader.readString(),
      category: reader.readString(),
      paymentType: reader.readString(),
      note: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, BBTransaction obj) {
    writer
      ..writeString(obj.id)
      ..writeInt(obj.amountCents)
      ..writeInt(obj.dateUtc.millisecondsSinceEpoch)
      ..writeString(obj.merchant)
      ..writeString(obj.category)
      ..writeString(obj.paymentType)
      ..writeString(obj.note);
  }
}
