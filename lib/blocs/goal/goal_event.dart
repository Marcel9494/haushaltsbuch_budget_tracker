import '../../data/models/goal.dart';

abstract class GoalEvent {}

class CreateGoal extends GoalEvent {
  final Goal goal;

  CreateGoal({
    required this.goal,
  });
}
