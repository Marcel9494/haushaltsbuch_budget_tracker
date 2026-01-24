import '../../data/models/goal.dart';

abstract class GoalEvent {}

class CreateGoal extends GoalEvent {
  final Goal goal;

  CreateGoal({
    required this.goal,
  });
}

class UpdateGoal extends GoalEvent {
  final Goal goal;

  UpdateGoal({
    required this.goal,
  });
}

class DeleteGoal extends GoalEvent {
  final String goalId;

  DeleteGoal({
    required this.goalId,
  });
}

class LoadGoals extends GoalEvent {
  LoadGoals();
}
