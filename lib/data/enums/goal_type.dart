enum GoalType {
  undefined,
  expense,
  income;

  static GoalType fromString(String s) => switch (s) {
        '' => GoalType.undefined,
        'Ausgabe' => GoalType.expense,
        'Einnahme' => GoalType.income,
        _ => GoalType.undefined,
      };
}

extension CategoryTypeExtension on GoalType {
  String get name {
    switch (this) {
      case GoalType.undefined:
        return '';
      case GoalType.expense:
        return 'Ausgabe';
      case GoalType.income:
        return 'Einnahme';
    }
  }
}
