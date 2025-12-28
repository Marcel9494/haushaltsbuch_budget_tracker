import '../../data/models/budget.dart';

abstract class BudgetState {}

class BudgetInitial extends BudgetState {}

class BudgetCreated extends BudgetState {
  final Budget budget;
  BudgetCreated(this.budget);
}

class BudgetLoading extends BudgetState {}

class BudgetListLoaded extends BudgetState {
  final List<Budget> budgets;
  BudgetListLoaded(this.budgets);
}

class BudgetError extends BudgetState {
  final String message;
  BudgetError(this.message);
}
