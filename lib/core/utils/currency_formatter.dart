import 'package:intl/intl.dart';

/// Formatter for Joyscoop prices and revenues (Strictly from DESIGN.md: ₹ symbol, no decimals)
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static String format(num amount) {
    return _formatter.format(amount);
  }

  /// Compact/clean integer price representation
  static String formatInt(int amount) {
    return _formatter.format(amount);
  }
}

