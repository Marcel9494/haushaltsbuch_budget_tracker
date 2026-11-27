import '../../core/utils/moneybook_value_parser.dart';

// Konto aus der Tabelle "accounts" einer Moneybook-Sicherung.
class MoneybookAccount {
  final String name;
  // z.B. "konto", "bargeld", "karte", "kapitalanlage"
  final String type;
  // Aktueller Kontostand, enthält bereits alle gebuchten Buchungen.
  final double amount;

  const MoneybookAccount({
    required this.name,
    required this.type,
    required this.amount,
  });

  factory MoneybookAccount.fromMap(Map<String, Object?> map) {
    return MoneybookAccount(
      name: readMoneybookString(map['name']),
      type: readMoneybookString(map['type']),
      amount: readMoneybookDouble(map['amount']),
    );
  }
}
