import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../features/bookings/data/enums/repetition_type.dart';

// Beispielausgabe: "1 Jahr, 2 Monate, 3 Wochen, 4 Tage\n(438 Tage)"
String formatDateDuration(DateTime startDate, DateTime endDate) {
  if (endDate.isBefore(startDate)) {
    return '';
  }

  final int totalDays = endDate.difference(startDate).inDays;

  int years = 0;
  int months = 0;

  DateTime tempDate = DateTime(startDate.year, startDate.month, startDate.day);

  // Jahre zählen
  while (DateTime(tempDate.year + 1, tempDate.month, tempDate.day).isBefore(endDate) ||
      DateTime(tempDate.year + 1, tempDate.month, tempDate.day).isAtSameMomentAs(endDate)) {
    years++;
    tempDate = DateTime(tempDate.year + 1, tempDate.month, tempDate.day);
  }

  // Monate zählen
  while (DateTime(tempDate.year, tempDate.month + 1, tempDate.day).isBefore(endDate) ||
      DateTime(tempDate.year, tempDate.month + 1, tempDate.day).isAtSameMomentAs(endDate)) {
    months++;
    tempDate = DateTime(tempDate.year, tempDate.month + 1, tempDate.day);
  }

  // Resttage
  int days = endDate.difference(tempDate).inDays;

  // Wochen extrahieren
  int weeks = days ~/ 7;
  days = days % 7;

  List<String> dateParts = [];

  if (years > 0) dateParts.add('$years Jahr${years > 1 ? 'e' : ''}');
  if (months > 0) dateParts.add('$months Monat${months > 1 ? 'e' : ''}');
  if (weeks > 0) dateParts.add('$weeks Woche${weeks > 1 ? 'n' : ''}');
  if (days > 0) dateParts.add('$days Tag${days > 1 ? 'e' : ''}');

  String mainDatePart = dateParts.isEmpty ? '0 Tage' : dateParts.join(', ');

  return '$mainDatePart\n($totalDays Tage)';
}

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

// Beispielausgabe: ["Januar", "Februar", ...]
List<String> getAllMonthNames(String locale) {
  List<String> monthNames = [];
  DateTime date = DateTime(DateTime.now().year, 1, 1);

  for (int i = 0; i < 12; i++) {
    String monthName = DateFormat.MMMM(locale).format(date);
    monthNames.add(monthName);
    date = DateTime(date.year, date.month + 1, 1);
  }
  return monthNames;
}

// Beispielausgabe: ["Jan", "Feb", ...]
List<String> getAllShortMonthNames(String locale) {
  List<String> shortMonthNames = [];
  DateTime date = DateTime(DateTime.now().year, 1, 1);

  for (int i = 0; i < 12; i++) {
    String monthName = DateFormat.MMM(locale).format(date);
    shortMonthNames.add(monthName);
    date = DateTime(date.year, date.month + 1, 1);
  }
  return shortMonthNames;
}

DateTime tryParseSelectedDate(String date) {
  try {
    return DateFormat(
      '(E) dd.MM.yyyy',
      WidgetsBinding.instance.platformDispatcher.locale.toString(),
    ).parseStrict(date);
  } catch (_) {
    return DateTime.now();
  }
}

String setDateForRepetitionType(String currentDate, RepetitionType repetitionType) {
  String dateString = '';
  final date = tryParseSelectedDate(currentDate);
  if (repetitionType == RepetitionType.beginningOfMonth) {
    dateString =
        DateFormat('(E) dd.MM.yyyy', WidgetsBinding.instance.platformDispatcher.locale.toString()).format(DateTime(date.year, date.month, 1));
  } else if (repetitionType == RepetitionType.endOfMonth) {
    dateString =
        DateFormat('(E) dd.MM.yyyy', WidgetsBinding.instance.platformDispatcher.locale.toString()).format(DateTime(date.year, date.month + 1, 0));
  } else if (repetitionType == RepetitionType.beginningOfYear) {
    dateString = DateFormat('(E) dd.MM.yyyy', WidgetsBinding.instance.platformDispatcher.locale.toString()).format(DateTime(date.year, 1, 1));
  } else if (repetitionType == RepetitionType.endOfYear) {
    dateString = DateFormat('(E) dd.MM.yyyy', WidgetsBinding.instance.platformDispatcher.locale.toString()).format(DateTime(date.year, 12, 31));
  } else {
    dateString = DateFormat('(E) dd.MM.yyyy', WidgetsBinding.instance.platformDispatcher.locale.toString()).format(date);
  }
  return dateString;
}
