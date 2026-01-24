import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/goal.dart';
import '../../data/repositories/goal_repository.dart';
import 'goal_event.dart';
import 'goal_state.dart';

class GoalBloc extends Bloc<GoalEvent, GoalState> {
  final GoalRepository _goalRepository;

  GoalBloc(this._goalRepository) : super(GoalInitial()) {
    on<CreateGoal>(_onCreateGoal);
    on<UpdateGoal>(_onUpdateGoal);
    on<DeleteGoal>(_onDeleteGoal);
    on<LoadGoals>(_onLoadGoals);
  }

  Future<void> _onCreateGoal(CreateGoal event, Emitter<GoalState> emit) async {
    emit(GoalLoading());
    try {
      final Goal createdGoal = await _goalRepository.createGoal(event.goal);
      emit(GoalCreated(createdGoal));
    } catch (e) {
      if (e.toString().contains('duplicated_goal')) {
        emit(GoalError('duplicated_goal_error'));
      } else {
        emit(GoalError('create_goal_error'));
      }
    }
  }

  Future<void> _onUpdateGoal(UpdateGoal event, Emitter<GoalState> emit) async {
    try {
      Goal updatedGoal = await _goalRepository.updateGoal(event.goal);
      emit(GoalUpdated(updatedGoal));
    } catch (e) {
      if (e.toString().contains('duplicated_goal')) {
        emit(GoalError('duplicated_goal_error'));
      } else {
        emit(GoalError('update_goal_error'));
      }
    }
  }

  Future<void> _onDeleteGoal(DeleteGoal event, Emitter<GoalState> emit) async {
    try {
      await _goalRepository.deleteGoal(event.goalId);
      final goals = await _goalRepository.loadGoals();
      emit(GoalListLoaded(goals));
    } catch (e) {
      emit(GoalError('delete_goal_error'));
    }
  }

  Future<void> _onLoadGoals(LoadGoals event, Emitter<GoalState> emit) async {
    emit(GoalLoading());
    try {
      final List<Goal> goals = await _goalRepository.loadGoals();
      emit(GoalListLoaded(goals));
    } catch (e) {
      emit(GoalError('load_goals_error'));
    }
  }
}
