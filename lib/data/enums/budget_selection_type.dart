enum BudgetSelectionType {
  single,
  onlyFuture,
  all;

  static BudgetSelectionType fromString(String s) => switch (s) {
        '' => BudgetSelectionType.single,
        'single_budget' => BudgetSelectionType.single,
        'future_budgets' => BudgetSelectionType.onlyFuture,
        'all_budgets' => BudgetSelectionType.all,
        _ => BudgetSelectionType.single,
      };
}

extension SelectionTypeExtension on BudgetSelectionType {
  String get name {
    switch (this) {
      case BudgetSelectionType.single:
        return 'single_budget';
      case BudgetSelectionType.onlyFuture:
        return 'future_budgets';
      case BudgetSelectionType.all:
        return 'all_budgets';
    }
  }

  String updateDescription(String budgetName) {
    switch (this) {
      case BudgetSelectionType.single:
        return 'update_single_budget_description';
      case BudgetSelectionType.onlyFuture:
        return 'update_future_budgets_description';
      case BudgetSelectionType.all:
        return 'update_all_budgets_description';
    }
  }

  String deleteDescription(String budgetName) {
    switch (this) {
      case BudgetSelectionType.single:
        return 'delete_single_budget_description';
      case BudgetSelectionType.onlyFuture:
        return 'delete_future_budgets_description';
      case BudgetSelectionType.all:
        return 'delete_all_budgets_description';
    }
  }
}
