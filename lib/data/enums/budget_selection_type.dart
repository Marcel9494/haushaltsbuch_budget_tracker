enum BudgetSelectionType {
  single,
  onlyFuture,
  all;

  static BudgetSelectionType fromString(String s) => switch (s) {
        '' => BudgetSelectionType.single,
        'Einzelnes Budget' => BudgetSelectionType.single,
        'Nur Zukünftige Budgets' => BudgetSelectionType.onlyFuture,
        'Alle Budgets' => BudgetSelectionType.all,
        _ => BudgetSelectionType.single,
      };
}

extension SelectionTypeExtension on BudgetSelectionType {
  String get name {
    switch (this) {
      case BudgetSelectionType.single:
        return 'Einzelnes Budget';
      case BudgetSelectionType.onlyFuture:
        return 'Nur Zukünftige Budgets';
      case BudgetSelectionType.all:
        return 'Alle Budgets';
    }
  }

  String updateDescription(String budgetName) {
    switch (this) {
      case BudgetSelectionType.single:
        return 'Änderungen gelten nur für das aktuelle $budgetName Budget.';
      case BudgetSelectionType.onlyFuture:
        return 'Änderungen gelten nur für zukünftige $budgetName Budgets.';
      case BudgetSelectionType.all:
        return 'Änderungen gelten für alle $budgetName Budgets.';
    }
  }

  String deleteDescription(String budgetName) {
    switch (this) {
      case BudgetSelectionType.single:
        return 'Es wird das aktuelle $budgetName Budget gelöscht.';
      case BudgetSelectionType.onlyFuture:
        return 'Es werden nur zukünftige $budgetName Budgets gelöscht.';
      case BudgetSelectionType.all:
        return 'Es werden alle $budgetName Budgets gelöscht.';
    }
  }
}
