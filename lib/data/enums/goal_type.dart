enum GoalType {
  undefined,
  payOff,
  saving;

  static GoalType fromString(String s) => switch (s) {
        '' => GoalType.undefined,
        'Abbezahlen' => GoalType.payOff,
        'Sparen' => GoalType.saving,
        _ => GoalType.undefined,
      };
}

extension GoalTypeExtension on GoalType {
  String get name {
    switch (this) {
      case GoalType.undefined:
        return '';
      case GoalType.payOff:
        return 'Abbezahlen';
      case GoalType.saving:
        return 'Sparen';
    }
  }
}
