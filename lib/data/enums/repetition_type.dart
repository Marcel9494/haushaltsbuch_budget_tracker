import '../../core/utils/date_helper.dart';

enum RepetitionType {
  noRepetition,
  weekly,
  twoWeekly,
  monthly,
  beginningOfMonth,
  endOfMonth,
  quarterly,
  halfYearly,
  yearly,
  beginningOfYear,
  endOfYear;

  static RepetitionType fromString(String s) => switch (s) {
        'no_repetition' => RepetitionType.noRepetition,
        'weekly' => RepetitionType.weekly,
        'two_weekly' => RepetitionType.twoWeekly,
        'monthly' => RepetitionType.monthly,
        'beginning_of_month' => RepetitionType.beginningOfMonth,
        'end_of_month' => RepetitionType.endOfMonth,
        'quarterly' => RepetitionType.quarterly,
        'half_yearly' => RepetitionType.halfYearly,
        'yearly' => RepetitionType.yearly,
        'beginning_of_year' => RepetitionType.beginningOfYear,
        'end_of_year' => RepetitionType.endOfYear,
        _ => RepetitionType.noRepetition
      };

  // Berechnet das nächste Buchungsdatum einer Serie über den Kalender (nicht über Stunden),
  // damit Zeitumstellungen (Sommer-/Winterzeit) das Datum nicht verschieben.
  // anchorDay ist der Starttag der Serie, z.B. 31 -> 31.01., 28.02., 31.03., 30.04., ...
  static DateTime getNextBookingDate(
    DateTime current,
    RepetitionType repetitionType, {
    int? anchorDay,
  }) {
    switch (repetitionType) {
      case RepetitionType.noRepetition:
        return current;

      case RepetitionType.weekly:
        return DateTime(current.year, current.month, current.day + 7);

      case RepetitionType.twoWeekly:
        return DateTime(current.year, current.month, current.day + 14);

      case RepetitionType.beginningOfMonth:
        return DateTime(current.year, current.month + 1, 1);

      case RepetitionType.endOfMonth:
        return DateTime(current.year, current.month + 2, 0);

      case RepetitionType.monthly:
        return addMonthsClamped(current, 1, anchorDay: anchorDay);

      case RepetitionType.quarterly:
        return addMonthsClamped(current, 3, anchorDay: anchorDay);

      case RepetitionType.halfYearly:
        return addMonthsClamped(current, 6, anchorDay: anchorDay);

      case RepetitionType.yearly:
        return addMonthsClamped(current, 12, anchorDay: anchorDay);

      case RepetitionType.beginningOfYear:
        return DateTime(current.year + 1, 1, 1);

      case RepetitionType.endOfYear:
        return DateTime(current.year + 1, 12, 31);
    }
  }
}

extension AmountTypeExtension on RepetitionType {
  String get name {
    switch (this) {
      case RepetitionType.noRepetition:
        return 'no_repetition';
      case RepetitionType.weekly:
        return 'weekly';
      case RepetitionType.twoWeekly:
        return 'two_weekly';
      case RepetitionType.monthly:
        return 'monthly';
      case RepetitionType.beginningOfMonth:
        return 'beginning_of_month';
      case RepetitionType.endOfMonth:
        return 'end_of_month';
      case RepetitionType.quarterly:
        return 'quarterly';
      case RepetitionType.halfYearly:
        return 'half_yearly';
      case RepetitionType.yearly:
        return 'yearly';
      case RepetitionType.beginningOfYear:
        return 'beginning_of_year';
      case RepetitionType.endOfYear:
        return 'end_of_year';
    }
  }
}
