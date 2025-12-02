enum PeriodOfTimeType {
  undefined,
  monthly,
  yearly;

  static PeriodOfTimeType fromString(String s) => switch (s) {
        '' => PeriodOfTimeType.undefined,
        'Monatlich' => PeriodOfTimeType.monthly,
        'Jährlich' => PeriodOfTimeType.yearly,
        _ => PeriodOfTimeType.undefined
      };
}
