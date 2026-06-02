enum GoalStateType {
  active,
  completed;

  static GoalStateType fromString(String s) => switch (s) {
        'active' => GoalStateType.active,
        'completed' => GoalStateType.completed,
        _ => GoalStateType.active,
      };
}

extension GoalStateExtension on GoalStateType {
  String get name {
    switch (this) {
      case GoalStateType.active:
        return 'active';
      case GoalStateType.completed:
        return 'completed';
    }
  }
}
