import '../../core/utils/moneybook_value_parser.dart';

// Monatsbudget aus der Tabelle "budgets" einer Moneybook-Sicherung.
// Moneybook legt pro Kategorie und Monat einen eigenen Eintrag an.
class MoneybookBudget {
  final String categorie;
  final DateTime? date;
  final double amount;

  const MoneybookBudget({
    required this.categorie,
    required this.date,
    required this.amount,
  });

  factory MoneybookBudget.fromMap(Map<String, Object?> map) {
    return MoneybookBudget(
      categorie: readMoneybookString(map['categorie']),
      date: readMoneybookDate(map['date']),
      amount: readMoneybookDouble(map['amount']),
    );
  }
}
