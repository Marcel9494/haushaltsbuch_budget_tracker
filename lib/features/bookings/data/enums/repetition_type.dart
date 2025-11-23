enum RepetitionType {
  none,
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
        'Keine Wiederholung' => RepetitionType.none,
        'Jede Woche' => RepetitionType.weekly,
        'Jede 2 Wochen' => RepetitionType.twoWeekly,
        'Jeden Monat' => RepetitionType.monthly,
        'Anfang des Monats' => RepetitionType.beginningOfMonth,
        'Ende des Monats' => RepetitionType.endOfMonth,
        'Quartalsweise' => RepetitionType.quarterly,
        'Halbjährlich' => RepetitionType.halfYearly,
        'Jährlich' => RepetitionType.yearly,
        'Anfang des Jahres' => RepetitionType.beginningOfYear,
        'Ende des Jahres' => RepetitionType.endOfYear,
        _ => RepetitionType.none
      };
}

extension AmountTypeExtension on RepetitionType {
  String get name {
    switch (this) {
      case RepetitionType.none:
        return 'Keine Wiederholung';
      case RepetitionType.weekly:
        return 'Jede Woche';
      case RepetitionType.twoWeekly:
        return 'Jede 2 Wochen';
      case RepetitionType.monthly:
        return 'Jeden Monat';
      case RepetitionType.beginningOfMonth:
        return 'Anfang des Monats';
      case RepetitionType.endOfMonth:
        return 'Ende des Monats';
      case RepetitionType.quarterly:
        return 'Quartalsweise';
      case RepetitionType.halfYearly:
        return 'Halbjährlich';
      case RepetitionType.yearly:
        return 'Jährlich';
      case RepetitionType.beginningOfYear:
        return 'Anfang des Jahres';
      case RepetitionType.endOfYear:
        return 'Ende des Jahres';
    }
  }
}
