import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class CurrencyHelper {
  CurrencyHelper._();

  static final CurrencyHelper instance = CurrencyHelper._();

  String _currencyCode = 'EUR';

  String get currencyCode => _currencyCode;

  void setCurrency(String currencyCode) {
    _currencyCode = currencyCode;
  }

  String formatCurrency(double amount, BuildContext context, {int decimalDigits = 2}) {
    final locale = Localizations.localeOf(context).toString();

    final format = NumberFormat.currency(
      locale: locale,
      symbol: NumberFormat.simpleCurrency(name: _currencyCode).currencySymbol,
      decimalDigits: decimalDigits,
    );

    return format.format(amount);
  }

  NumberFormat formatter(
    BuildContext context, {
    int decimalDigits = 2,
  }) {
    final locale = Localizations.localeOf(context).toString();

    return NumberFormat.currency(
      locale: locale,
      symbol: getSymbol(),
      decimalDigits: decimalDigits,
    );
  }

  String format(
    double amount,
    BuildContext context, {
    int decimalDigits = 2,
  }) {
    return formatter(
      context,
      decimalDigits: decimalDigits,
    ).format(amount);
  }

  double parseAmount(String input, BuildContext context) {
    final format = formatter(context);

    String cleaned = input
        .replaceAll(format.currencySymbol, '')
        .replaceAll(format.symbols.GROUP_SEP, '')
        .replaceAll(
          format.symbols.DECIMAL_SEP,
          '.',
        )
        .trim();

    return double.tryParse(cleaned) ?? 0;
  }

  String getSymbol() {
    return NumberFormat.simpleCurrency(
      name: _currencyCode,
    ).currencySymbol;
  }

  String getDecimalSeparator(BuildContext context) {
    return formatter(context).symbols.DECIMAL_SEP;
  }

  String getGroupSeparator(BuildContext context) {
    return formatter(context).symbols.GROUP_SEP;
  }
}
