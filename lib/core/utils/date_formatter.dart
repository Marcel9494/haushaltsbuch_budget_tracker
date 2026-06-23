import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

String formatMonthYear(BuildContext context, DateTime date) {
  final locale = Localizations.localeOf(context).toString();
  return DateFormat("MMM yyy", locale).format(date);
}

String formatShortMonth(BuildContext context, DateTime date) {
  final locale = Localizations.localeOf(context).toString();
  final month = DateFormat("MMM", locale).format(date);
  return month.endsWith('.') ? month : '$month.';
}

String formatLongMonth(BuildContext context, DateTime date) {
  final locale = Localizations.localeOf(context).toString();
  final month = DateFormat("MMMM", locale).format(date);
  return month;
}

String formatYear(BuildContext context, DateTime date) {
  final locale = Localizations.localeOf(context).toString();
  return DateFormat("yyy", locale).format(date);
}
