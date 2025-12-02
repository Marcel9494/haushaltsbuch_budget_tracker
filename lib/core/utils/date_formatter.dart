import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

String formatMonthYear(BuildContext context, DateTime date) {
  final locale = Localizations.localeOf(context).toString();
  return DateFormat("MMM yyy", locale).format(date);
}
