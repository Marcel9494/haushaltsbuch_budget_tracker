import '../../data/models/budget.dart';

abstract class BudgetEvent {}

class CreateBudget extends BudgetEvent {
  final Budget budget;

  CreateBudget({
    required this.budget,
  });
}

class LoadMonthlyBudgets extends BudgetEvent {
  final DateTime currentSelectedDate;

  LoadMonthlyBudgets(
    this.currentSelectedDate,
  );
}

class LoadYearlyBudgets extends BudgetEvent {
  final int selectedYear;

  LoadYearlyBudgets({
    required this.selectedYear,
  });
}
