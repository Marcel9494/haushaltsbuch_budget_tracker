import '../../data/models/budget.dart';

abstract class BudgetState {}

class BudgetInitial extends BudgetState {}

class BudgetCreated extends BudgetState {
  BudgetCreated();
}

class BudgetUpdated extends BudgetState {
  BudgetUpdated();
}

class BudgetLoading extends BudgetState {}

class BudgetListLoaded extends BudgetState {
  final List<Budget> budgets;
  BudgetListLoaded(this.budgets);
}

class YearlyBudgetListLoaded extends BudgetState {
  final Map<String, List<Budget>> yearlyBudgets;
  YearlyBudgetListLoaded(this.yearlyBudgets);
}

class YearlyBudgetFromCategoryListLoaded extends BudgetState {
  final Map<String, List<Budget>> yearlyBudgetsFromCategory;
  YearlyBudgetFromCategoryListLoaded(this.yearlyBudgetsFromCategory);
}

class BudgetError extends BudgetState {
  final String message;
  BudgetError(this.message);
}
