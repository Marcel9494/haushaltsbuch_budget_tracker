import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

double parseAmount(String amount) {
  final cleaned = amount.replaceAll('€', '').replaceAll('.', '').replaceAll(',', '.').trim();
  return double.parse(cleaned);
}

class CurrencyHelper {
  CurrencyHelper._privateConstructor();

  static final CurrencyHelper instance = CurrencyHelper._privateConstructor();

  String _currencyCode = 'EUR';

  String get currencyCode => _currencyCode;

  void setCurrency(String currencyCode) {
    _currencyCode = currencyCode;
  }

  String formatCurrency(
    double amount,
    BuildContext context, {
    int decimalDigits = 2,
  }) {
    final locale = Localizations.localeOf(context).toString();

    final format = NumberFormat.currency(
      locale: locale,
      symbol: NumberFormat.simpleCurrency(name: _currencyCode).currencySymbol,
      decimalDigits: decimalDigits,
    );

    return format.format(amount);
  }

  double parseAmount(String amount) {
    final symbol = NumberFormat.simpleCurrency(
      name: _currencyCode,
    ).currencySymbol;

    final cleaned = amount.replaceAll(symbol, '').replaceAll('.', '').replaceAll(',', '.').trim();

    return double.parse(cleaned);
  }
}
