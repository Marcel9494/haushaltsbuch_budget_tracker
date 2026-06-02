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
    on<LoadActiveGoals>(_onLoadActiveGoals);
    on<LoadCompletedGoals>(_onLoadCompletedGoals);
    on<CompleteGoal>(_onCompleteGoal);
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
      final goals = await _goalRepository.loadActiveGoals();
      emit(GoalListLoaded(goals));
    } catch (e) {
      emit(GoalError('delete_goal_error'));
    }
  }

  Future<void> _onLoadActiveGoals(LoadActiveGoals event, Emitter<GoalState> emit) async {
    emit(GoalLoading());
    try {
      final List<Goal> activeGoals = await _goalRepository.loadActiveGoals();
      emit(GoalListLoaded(activeGoals));
    } catch (e) {
      emit(GoalError('load_goals_error'));
    }
  }

  Future<void> _onLoadCompletedGoals(LoadCompletedGoals event, Emitter<GoalState> emit) async {
    emit(GoalLoading());
    try {
      final List<Goal> completedGoals = await _goalRepository.loadCompletedGoals();
      emit(GoalListLoaded(completedGoals));
    } catch (e) {
      emit(GoalError('load_goals_error'));
    }
  }

  Future<void> _onCompleteGoal(CompleteGoal event, Emitter<GoalState> emit) async {
    try {
      Goal completedGoal = await _goalRepository.completeGoal(event.goalId);
      emit(GoalCompleted(completedGoal));
    } catch (e) {
      emit(GoalError('complete_goal_error'));
    }
  }
}
