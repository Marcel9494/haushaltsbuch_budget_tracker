import '../../core/utils/moneybook_value_parser.dart';

// Ziel aus der Tabelle "goals" einer Moneybook-Sicherung.
class MoneybookGoal {
  final String name;
  final double goalAmount;
  final DateTime? startDate;
  final DateTime? endDate;
  // z.B. "Sparziel" oder "Ausgabenziel"
  final String type;

  const MoneybookGoal({
    required this.name,
    required this.goalAmount,
    required this.startDate,
    required this.endDate,
    required this.type,
  });

  factory MoneybookGoal.fromMap(Map<String, Object?> map) {
    return MoneybookGoal(
      name: readMoneybookString(map['name']),
      goalAmount: readMoneybookDouble(map['goalAmount']),
      startDate: readMoneybookDate(map['startDate']),
      endDate: readMoneybookDate(map['endDate']),
      type: readMoneybookString(map['type']),
    );
  }
}
