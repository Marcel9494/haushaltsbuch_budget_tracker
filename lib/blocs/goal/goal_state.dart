import '../../data/models/goal.dart';

abstract class GoalState {}

class GoalInitial extends GoalState {}

class GoalCreated extends GoalState {
  final Goal goal;
  GoalCreated(this.goal);
}

class GoalLoading extends GoalState {}

class GoalListLoaded extends GoalState {
  final List<Goal> goals;
  GoalListLoaded(this.goals);
}

class GoalError extends GoalState {
  final String message;
  GoalError(this.message);
}
