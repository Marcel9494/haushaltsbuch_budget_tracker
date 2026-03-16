enum DashboardElementType {
  month,
  year,
  general;

  static DashboardElementType fromString(String s) => switch (s) {
        'general' => DashboardElementType.general,
        'month' => DashboardElementType.month,
        'year' => DashboardElementType.year,
        _ => DashboardElementType.general,
      };
}

extension DashboardElementTypeExtension on DashboardElementType {
  String get name {
    switch (this) {
      case DashboardElementType.general:
        return 'general';
      case DashboardElementType.month:
        return 'month';
      case DashboardElementType.year:
        return 'year';
    }
  }
}
