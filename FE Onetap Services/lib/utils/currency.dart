import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static String inr(num value) {
    final hasFraction = value % 1 != 0;
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '\u20B9 ',
      decimalDigits: hasFraction ? 2 : 0,
    );
    return formatter.format(value);
  }
}
