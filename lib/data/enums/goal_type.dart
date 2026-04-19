enum GoalType {
  undefined,
  saving,
  payOff;

  static GoalType fromString(String s) => switch (s) {
        '' => GoalType.undefined,
        'saving' => GoalType.saving,
        'pay_off' => GoalType.payOff,
        _ => GoalType.undefined,
      };
}

extension GoalTypeExtension on GoalType {
  String get name {
    switch (this) {
      case GoalType.undefined:
        return '';
      case GoalType.saving:
        return 'saving';
      case GoalType.payOff:
        return 'pay_off';
    }
  }
}
