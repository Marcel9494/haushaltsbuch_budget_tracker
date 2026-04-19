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

  static DateTime getNextBookingDate(
    DateTime current,
    RepetitionType repetitionType,
  ) {
    switch (repetitionType) {
      case RepetitionType.noRepetition:
        return current;

      case RepetitionType.weekly:
        return current.add(const Duration(days: 7));

      case RepetitionType.twoWeekly:
        return current.add(const Duration(days: 14));

      case RepetitionType.beginningOfMonth:
        return DateTime(
          current.year,
          current.month + 1,
          1,
        );

      case RepetitionType.endOfMonth:
        return DateTime(
          current.year,
          current.month + 2,
          0,
        );

      case RepetitionType.monthly:
        return DateTime(
          current.year,
          current.month + 1,
          current.day,
        );

      case RepetitionType.quarterly:
        return DateTime(
          current.year,
          current.month + 3,
          current.day,
        );

      case RepetitionType.halfYearly:
        return DateTime(
          current.year,
          current.month + 6,
          current.day,
        );

      case RepetitionType.yearly:
        return DateTime(
          current.year + 1,
          current.month,
          current.day,
        );

      case RepetitionType.beginningOfYear:
        return DateTime(
          current.year + 1,
          1,
          1,
        );

      case RepetitionType.endOfYear:
        return DateTime(
          current.year + 1,
          12,
          31,
        );
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
