import '../../core/utils/moneybook_value_parser.dart';

// Kategorie aus der Tabelle "categories" einer Moneybook-Sicherung.
class MoneybookCategory {
  final String name;
  // "Ausgabe", "Einnahme" oder "Investition"
  final String type;

  const MoneybookCategory({
    required this.name,
    required this.type,
  });

  factory MoneybookCategory.fromMap(Map<String, Object?> map) {
    return MoneybookCategory(
      name: readMoneybookString(map['name']),
      type: readMoneybookString(map['type']),
    );
  }
}
