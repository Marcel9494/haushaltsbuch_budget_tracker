// Beispielausgabe: "1 Jahr, 2 Monate, 3 Wochen, 4 Tage\n(438 Tage)"
String formatDateDuration(DateTime startDate, DateTime endDate) {
  if (endDate.isBefore(startDate)) {
    return '';
  }

  final int totalDays = endDate.difference(startDate).inDays;

  int years = 0;
  int months = 0;

  DateTime tempDate = DateTime(startDate.year, startDate.month, startDate.day);

  // Jahre zählen
  while (DateTime(tempDate.year + 1, tempDate.month, tempDate.day).isBefore(endDate) ||
      DateTime(tempDate.year + 1, tempDate.month, tempDate.day).isAtSameMomentAs(endDate)) {
    years++;
    tempDate = DateTime(tempDate.year + 1, tempDate.month, tempDate.day);
  }

  // Monate zählen
  while (DateTime(tempDate.year, tempDate.month + 1, tempDate.day).isBefore(endDate) ||
      DateTime(tempDate.year, tempDate.month + 1, tempDate.day).isAtSameMomentAs(endDate)) {
    months++;
    tempDate = DateTime(tempDate.year, tempDate.month + 1, tempDate.day);
  }

  // Resttage
  int days = endDate.difference(tempDate).inDays;

  // Wochen extrahieren
  int weeks = days ~/ 7;
  days = days % 7;

  List<String> dateParts = [];

  if (years > 0) dateParts.add('$years Jahr${years > 1 ? 'e' : ''}');
  if (months > 0) dateParts.add('$months Monat${months > 1 ? 'e' : ''}');
  if (weeks > 0) dateParts.add('$weeks Woche${weeks > 1 ? 'n' : ''}');
  if (days > 0) dateParts.add('$days Tag${days > 1 ? 'e' : ''}');

  String mainDatePart = dateParts.isEmpty ? '0 Tage' : dateParts.join(', ');

  return '$mainDatePart\n($totalDays Tage)';
}

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
