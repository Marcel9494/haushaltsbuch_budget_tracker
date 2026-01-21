import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/budget.dart';
import '../../data/repositories/budget_repository.dart';
import 'budget_event.dart';
import 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final BudgetRepository _budgetRepository;

  BudgetBloc(this._budgetRepository) : super(BudgetInitial()) {
    on<CreateBudget>(_onCreateBudget);
    on<UpdateBudget>(_onUpdateBudget);
    on<LoadMonthlyBudgets>(_onLoadMonthlyBudgets);
    on<LoadYearlyBudgets>(_onLoadYearlyBudgets);
  }

  Future<void> _onCreateBudget(CreateBudget event, Emitter<BudgetState> emit) async {
    emit(BudgetLoading());
    try {
      _budgetRepository.createBudgets(event.budget);
      emit(BudgetCreated());
    } catch (e) {
      emit(BudgetError('create_budget_error'));
    }
  }

  Future<void> _onUpdateBudget(UpdateBudget event, Emitter<BudgetState> emit) async {
    emit(BudgetLoading());
    try {
      _budgetRepository.updateBudget(event.budget, event.budgetSelectionType);
      emit(BudgetUpdated());
    } catch (e) {
      emit(BudgetError('update_budget_error'));
    }
  }

  Future<void> _onLoadMonthlyBudgets(LoadMonthlyBudgets event, Emitter<BudgetState> emit) async {
    emit(BudgetLoading());
    try {
      final List<Budget> budgets = await _budgetRepository.loadMonthlyBudgets(event.currentSelectedDate);
      emit(BudgetListLoaded(budgets));
    } catch (e) {
      emit(BudgetError('load_budgets_error'));
    }
  }

  Future<void> _onLoadYearlyBudgets(LoadYearlyBudgets event, Emitter<BudgetState> emit) async {
    emit(BudgetLoading());
    try {
      final Map<String, List<Budget>> yearlyBudgets = await _budgetRepository.loadYearlyBudgets(event.selectedYear);
      emit(YearlyBudgetListLoaded(yearlyBudgets));
    } catch (e) {
      emit(BudgetError('load_budgets_error'));
    }
  }
}
