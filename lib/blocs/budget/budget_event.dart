import '../../data/models/budget.dart';

abstract class BudgetEvent {}

class CreateBudget extends BudgetEvent {
  final Budget budget;

  CreateBudget({
    required this.budget,
  });
}

class LoadBudgets extends BudgetEvent {
  LoadBudgets();
}
