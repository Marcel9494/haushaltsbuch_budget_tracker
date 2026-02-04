import 'package:haushaltsbuch_budget_tracker/data/enums/budget_selection_type.dart';

import '../../data/models/budget.dart';

class UpdateBudgetPageArguments {
  final Budget budget;
  final BudgetSelectionType budgetSelectionType;

  UpdateBudgetPageArguments(
    this.budget,
    this.budgetSelectionType,
  );
}
