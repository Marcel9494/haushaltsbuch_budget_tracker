import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/budget.dart';
import '../../data/repositories/budget_repository.dart';
import 'budget_event.dart';
import 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final BudgetRepository _budgetRepository;

  BudgetBloc(this._budgetRepository) : super(BudgetInitial()) {
    on<CreateBudget>(_onCreateBudget);
    on<LoadBudgets>(_onLoadBudgets);
  }

  Future<void> _onCreateBudget(CreateBudget event, Emitter<BudgetState> emit) async {
    emit(BudgetLoading());
    try {
      final Budget createdBudget = await _budgetRepository.createBudget(event.budget);
      emit(BudgetCreated(createdBudget));
    } catch (e) {
      emit(BudgetError('create_budget_error'));
    }
  }

  Future<void> _onLoadBudgets(LoadBudgets event, Emitter<BudgetState> emit) async {
    emit(BudgetLoading());
    try {
      final List<Budget> budgets = await _budgetRepository.loadBudgets();
      emit(BudgetListLoaded(budgets));
    } catch (e) {
      emit(BudgetError('load_budgets_error'));
    }
  }
}
