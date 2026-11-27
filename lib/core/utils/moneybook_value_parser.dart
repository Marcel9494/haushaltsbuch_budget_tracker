// Hilfsfunktionen zum Lesen einzelner Werte aus einer Moneybook-Sicherung (SQLite).
// SQLite speichert Werte ohne festen Typ, daher werden alle Werte tolerant gelesen.

String readMoneybookString(Object? value) {
  if (value == null) {
    return '';
  }
  return value.toString();
}

double readMoneybookDouble(Object? value) {
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
  }
  return 0.0;
}

int readMoneybookInt(Object? value, {int fallback = -1}) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value) ?? fallback;
  }
  return fallback;
}

// Moneybook speichert Wahrheitswerte als 0 / 1.
bool readMoneybookBool(Object? value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    return value == '1' || value.toLowerCase() == 'true';
  }
  return false;
}

// Moneybook speichert Datumswerte als "yyyy-MM-dd" (teilweise mit Uhrzeit).
// Gibt ein reines Kalenderdatum (00:00 Uhr, lokale Zeit) oder null bei ungültigen Werten zurück.
DateTime? readMoneybookDate(Object? value) {
  final String text = readMoneybookString(value).trim();
  if (text.length < 10) {
    return null;
  }
  final DateTime? parsedDate = DateTime.tryParse(text.substring(0, 10));
  if (parsedDate == null) {
    return null;
  }
  return DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
}
