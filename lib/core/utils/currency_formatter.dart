import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

String formatCurrency(double amount, String currencyCode, {int decimalDigits = 2}) {
  final locale = WidgetsBinding.instance.platformDispatcher.locale.toString();
  final format =
      NumberFormat.currency(locale: locale, symbol: NumberFormat.simpleCurrency(name: currencyCode).currencySymbol, decimalDigits: decimalDigits);
  return format.format(amount);
}

double parseAmount(String amount) {
  final cleaned = amount.replaceAll('€', '').replaceAll('.', '').replaceAll(',', '.').trim();
  return double.parse(cleaned);
}
