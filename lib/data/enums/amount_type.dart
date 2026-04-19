enum AmountType {
  none,
  variable,
  fix,
  active,
  passive;

  static AmountType fromString(String s) => switch (s) {
        'none' => AmountType.none,
        'variable' => AmountType.variable,
        'fix' => AmountType.fix,
        'active' => AmountType.active,
        'passive' => AmountType.passive,
        _ => AmountType.none,
      };
}

extension AmountTypeExtension on AmountType {
  String get name {
    switch (this) {
      case AmountType.none:
        return 'none';
      case AmountType.variable:
        return 'variable';
      case AmountType.fix:
        return 'fix';
      case AmountType.active:
        return 'active';
      case AmountType.passive:
        return 'passive';
    }
  }
}
