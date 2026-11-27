import '../../core/utils/moneybook_value_parser.dart';

// Buchung aus der Tabelle "bookings" einer Moneybook-Sicherung.
// Moneybook speichert Konten, Kategorien und Ziele über ihren Namen, nicht über eine Id.
class MoneybookBooking {
  // Gleiche serieId = gleiche Serienbuchung, -1 = keine Serie.
  final int serieId;
  // "Ausgabe", "Einnahme", "Übertrag" oder "Investition"
  final String type;
  final String title;
  final DateTime? date;
  // z.B. "keine_wiederholung", "jeden_monat", "am_monatsanfang"
  final String repetition;
  final double amount;
  // z.B. "variabel", "fix", "aktiv", "passiv", "kauf", "verkauf"
  final String amountType;
  // Abbuchungskonto (bei Ausgabe und Einnahme das einzige Konto)
  final String fromAccount;
  // Zielkonto bei Übertrag und Investition
  final String toAccount;
  final String categorie;
  final bool isBooked;
  // Name des Ziels, leer oder "Kein Ziel" wenn kein Ziel verknüpft ist.
  final String goal;

  const MoneybookBooking({
    required this.serieId,
    required this.type,
    required this.title,
    required this.date,
    required this.repetition,
    required this.amount,
    required this.amountType,
    required this.fromAccount,
    required this.toAccount,
    required this.categorie,
    required this.isBooked,
    required this.goal,
  });

  factory MoneybookBooking.fromMap(Map<String, Object?> map) {
    return MoneybookBooking(
      serieId: readMoneybookInt(map['serieId']),
      type: readMoneybookString(map['type']),
      title: readMoneybookString(map['title']),
      date: readMoneybookDate(map['date']),
      repetition: readMoneybookString(map['repetition']),
      amount: readMoneybookDouble(map['amount']),
      amountType: readMoneybookString(map['amountType']),
      fromAccount: readMoneybookString(map['fromAccount']),
      toAccount: readMoneybookString(map['toAccount']),
      categorie: readMoneybookString(map['categorie']),
      isBooked: readMoneybookBool(map['isBooked']),
      // Ältere Moneybook-Versionen haben noch keine Spalte "goal".
      goal: readMoneybookString(map['goal']),
    );
  }
}
