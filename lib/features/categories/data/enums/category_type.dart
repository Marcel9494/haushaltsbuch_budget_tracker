enum CategoryType {
  undefined,
  expenses,
  revenue;

  static CategoryType fromString(String s) => switch (s) {
        '' => CategoryType.undefined,
        'Ausgaben' => CategoryType.expenses,
        'Einnahmen' => CategoryType.revenue,
        _ => CategoryType.undefined
      };
}

extension CategoryTypeExtension on CategoryType {
  String get name {
    switch (this) {
      case CategoryType.undefined:
        return '';
      case CategoryType.expenses:
        return 'Ausgaben';
      case CategoryType.revenue:
        return 'Einnahmen';
    }
  }
}
