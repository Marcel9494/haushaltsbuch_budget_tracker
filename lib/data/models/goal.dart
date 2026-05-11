import '../enums/goal_type.dart';

class Goal {
  final String? id;
  final String? userId;
  final double? currentAmount;
  final double goalAmount;
  final String goalName;
  final GoalType goalType;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? reachedDate;

  Goal({
    this.id,
    this.userId,
    this.currentAmount,
    required this.goalAmount,
    required this.goalName,
    required this.goalType,
    required this.startDate,
    required this.endDate,
    this.reachedDate,
  });

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'],
      userId: map['user_id'],
      currentAmount: map['current_amount'],
      goalAmount: map['goal_amount'],
      goalName: map['goal_name'],
      goalType: GoalType.fromString(map['goal_type']),
      startDate: DateTime.parse(map['start_date']),
      endDate: DateTime.parse(map['end_date']),
      reachedDate: map['reached_date'] != null ? DateTime.parse(map['reached_date']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'goal_amount': goalAmount,
      'current_amount': currentAmount,
      'goal_name': goalName,
      'goal_type': goalType.name,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'reached_date': reachedDate?.toIso8601String(),
    };
  }
}
