enum NetWorthPeriodType {
  oneMonth,
  threeMonths,
  sixMonths,
  oneYear,
  threeYears,
  max;
}

extension NetWorthPeriodTypeExtension on NetWorthPeriodType {
  // Übersetzungsschlüssel für die Zeitraum-Auswahl
  String get translationKey {
    switch (this) {
      case NetWorthPeriodType.oneMonth:
        return 'net_worth_period_1m';
      case NetWorthPeriodType.threeMonths:
        return 'net_worth_period_3m';
      case NetWorthPeriodType.sixMonths:
        return 'net_worth_period_6m';
      case NetWorthPeriodType.oneYear:
        return 'net_worth_period_1y';
      case NetWorthPeriodType.threeYears:
        return 'net_worth_period_3y';
      case NetWorthPeriodType.max:
        return 'net_worth_period_max';
    }
  }

  // Startdatum des Zeitraums. Bei "Max" wird die erste gebuchte Buchung verwendet.
  DateTime getStartDate(DateTime today, DateTime? firstBookingDate) {
    final DateTime date = DateTime(today.year, today.month, today.day);
    switch (this) {
      case NetWorthPeriodType.oneMonth:
        return DateTime(date.year, date.month - 1, date.day);
      case NetWorthPeriodType.threeMonths:
        return DateTime(date.year, date.month - 3, date.day);
      case NetWorthPeriodType.sixMonths:
        return DateTime(date.year, date.month - 6, date.day);
      case NetWorthPeriodType.oneYear:
        return DateTime(date.year - 1, date.month, date.day);
      case NetWorthPeriodType.threeYears:
        return DateTime(date.year - 3, date.month, date.day);
      case NetWorthPeriodType.max:
        if (firstBookingDate == null) {
          return DateTime(date.year, date.month - 1, date.day);
        }
        // Einen Tag vor der ersten Buchung starten, damit der Ausgangswert sichtbar ist.
        final DateTime start = DateTime(firstBookingDate.year, firstBookingDate.month, firstBookingDate.day - 1);
        // Mindestens einen Monat anzeigen, damit das Diagramm nicht zu kurz wird.
        final DateTime minStart = DateTime(date.year, date.month - 1, date.day);
        return start.isBefore(minStart) ? start : minStart;
    }
  }
}
