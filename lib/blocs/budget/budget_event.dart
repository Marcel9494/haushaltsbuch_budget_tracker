import 'package:haushaltsbuch_budget_tracker/data/enums/budget_selection_type.dart';

import '../../data/models/budget.dart';

abstract class BudgetEvent {}

class CreateBudget extends BudgetEvent {
  final Budget budget;

  CreateBudget({
    required this.budget,
  });
}

class UpdateBudget extends BudgetEvent {
  final Budget budget;
  final BudgetSelectionType budgetSelectionType;

  UpdateBudget({
    required this.budget,
    required this.budgetSelectionType,
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
