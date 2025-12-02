import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

String formatCurrency(double amount, String currencyCode) {
  final locale = WidgetsBinding.instance.platformDispatcher.locale.toString();
  final format = NumberFormat.currency(
    locale: locale,
    symbol: NumberFormat.simpleCurrency(name: currencyCode).currencySymbol,
  );
  return format.format(amount);
}
