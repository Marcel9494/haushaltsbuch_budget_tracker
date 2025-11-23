enum AmountType {
  undefined,
  variable,
  fix,
  active,
  passive;

  static AmountType fromString(String s) => switch (s) {
        '' => AmountType.undefined,
        'Variabel' => AmountType.variable,
        'Fix' => AmountType.fix,
        'Aktiv' => AmountType.active,
        'Passiv' => AmountType.passive,
        _ => AmountType.undefined
      };
}

extension AmountTypeExtension on AmountType {
  String get name {
    switch (this) {
      case AmountType.undefined:
        return '';
      case AmountType.variable:
        return 'Variabel';
      case AmountType.fix:
        return 'Fix';
      case AmountType.active:
        return 'Aktiv';
      case AmountType.passive:
        return 'Passiv';
    }
  }
}
