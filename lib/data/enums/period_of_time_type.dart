enum PeriodOfTimeType {
  undefined,
  monthly,
  yearly;

  static PeriodOfTimeType fromString(String s) => switch (s) {
        '' => PeriodOfTimeType.undefined,
        'monthly' => PeriodOfTimeType.monthly,
        'yearly' => PeriodOfTimeType.yearly,
        _ => PeriodOfTimeType.undefined
      };
}
