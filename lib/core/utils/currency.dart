import 'package:intl/intl.dart';

final _currencyFormat = NumberFormat.simpleCurrency();

String formatCents(int amount) {
  return _currencyFormat.format(amount / 100);
}

int? parseCurrency(String input) {
  try {
    final value = _currencyFormat.parse(input).toDouble();
    return (value * 100).round();
  } catch (_) {
    return null;
  }
}
