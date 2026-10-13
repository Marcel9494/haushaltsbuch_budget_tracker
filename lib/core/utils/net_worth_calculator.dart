import '../../data/enums/account_type.dart';
import '../../data/enums/booking_type.dart';
import '../../data/helper_models/net_worth_booking.dart';
import '../../data/helper_models/net_worth_point.dart';
import '../../data/models/account.dart';

// Berechnet die Vermögensentwicklung (Saldo = Vermögen - Schulden) rückwärts
// aus den aktuellen Kontoständen und allen bereits gebuchten Buchungen.
//
// Idee: Der heutige Kontostand ist bekannt. Der Kontostand an einem Tag D ist der
// heutige Kontostand abzüglich aller Buchungen, die nach Tag D gebucht wurden.
// Pro Tag wird danach dieselbe Saldo-Formel wie auf der Kontoliste angewendet,
// damit der letzte Punkt im Diagramm exakt dem angezeigten Saldo entspricht.
class NetWorthCalculator {
  NetWorthCalculator._();

  // Saldo wie auf der Kontoliste: Vermögen - |Schulden|
  static double calculateNetWorth(Map<String, double> balances, Map<String, AccountType> accountTypes) {
    double assets = 0.0;
    double debts = 0.0;
    balances.forEach((accountId, balance) {
      final AccountType accountType = accountTypes[accountId] ?? AccountType.noAccountType;
      if (balance < 0 || accountType == AccountType.credit) {
        debts += balance;
      } else {
        assets += balance;
      }
    });
    return assets - debts.abs();
  }

  // Liefert die Datenpunkte vom Startdatum bis zum Enddatum (jeweils Tagesende).
  // Je nach Länge des Zeitraums werden tägliche, wöchentliche oder monatliche Punkte erzeugt.
  static List<NetWorthPoint> calculateHistory({
    required List<Account> accounts,
    required List<NetWorthBooking> bookings,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final DateTime start = _dateOnly(startDate);
    final DateTime end = _dateOnly(endDate);
    if (accounts.isEmpty || end.isBefore(start)) {
      return [];
    }

    final Map<String, double> balances = {};
    final Map<String, AccountType> accountTypes = {};
    for (final Account account in accounts) {
      if (account.id == null) {
        continue;
      }
      balances[account.id!] = account.balance;
      accountTypes[account.id!] = account.accountType;
    }

    // Saldoanpassungen sind keinem Konto zugeordnet und werden separat aufsummiert.
    double unassignedChange = 0.0;

    final List<DateTime> pointDates = _buildPointDates(start, end);

    // Neueste Buchungen zuerst, damit beim Rückwärtsgehen jede Buchung genau einmal abgezogen wird.
    final List<NetWorthBooking> sortedBookings = bookings.where((booking) => booking.isBooked).toList()
      ..sort((a, b) => b.bookingDate.compareTo(a.bookingDate));

    final List<NetWorthPoint> points = [];
    int bookingIndex = 0;

    for (int i = pointDates.length - 1; i >= 0; i--) {
      final DateTime pointDate = pointDates[i];

      // Alle Buchungen nach dem Tagesende von pointDate rückgängig machen.
      while (bookingIndex < sortedBookings.length && _dateOnly(sortedBookings[bookingIndex].bookingDate).isAfter(pointDate)) {
        unassignedChange += _revertBooking(sortedBookings[bookingIndex], balances);
        bookingIndex++;
      }

      points.add(NetWorthPoint(
        date: pointDate,
        netWorth: calculateNetWorth(balances, accountTypes) + unassignedChange,
      ));
    }

    return points.reversed.toList();
  }

  // Macht eine Buchung auf den Kontoständen rückgängig.
  // Rückgabe: Änderung, die keinem existierenden Konto zugeordnet werden kann (nur Saldoanpassungen).
  static double _revertBooking(NetWorthBooking booking, Map<String, double> balances) {
    switch (booking.bookingType) {
      case BookingType.income:
        if (booking.debitAccountId != null) {
          _changeBalance(balances, booking.debitAccountId!, -booking.amount);
        } else if (booking.isBalanceAdjustment) {
          return -booking.amount;
        }
        return 0.0;
      case BookingType.expense:
        if (booking.debitAccountId != null) {
          _changeBalance(balances, booking.debitAccountId!, booking.amount);
        } else if (booking.isBalanceAdjustment) {
          return booking.amount;
        }
        return 0.0;
      case BookingType.transfer:
        if (booking.debitAccountId != null) {
          _changeBalance(balances, booking.debitAccountId!, booking.amount);
        }
        if (booking.targetAccountId != null) {
          _changeBalance(balances, booking.targetAccountId!, -booking.amount);
        }
        return 0.0;
    }
  }

  // Gelöschte Konten werden ignoriert, da ihr Kontostand nicht mehr bekannt ist.
  static void _changeBalance(Map<String, double> balances, String accountId, double change) {
    if (balances.containsKey(accountId)) {
      balances[accountId] = balances[accountId]! + change;
    }
  }

  static List<DateTime> _buildPointDates(DateTime start, DateTime end) {
    final int totalDays = daysBetween(start, end);
    final int stepInDays = totalDays <= 400 ? 1 : 7;
    final bool monthlySteps = totalDays > 1500;

    final List<DateTime> dates = [];
    if (monthlySteps) {
      // Monatsende als Stützpunkt, z.B. 31.01., 28.02., ...
      DateTime date = DateTime(start.year, start.month + 1, 0);
      dates.add(start);
      while (date.isBefore(end)) {
        if (date.isAfter(start)) {
          dates.add(date);
        }
        date = DateTime(date.year, date.month + 2, 0);
      }
    } else {
      for (int day = 0; day < totalDays; day += stepInDays) {
        dates.add(DateTime(start.year, start.month, start.day + day));
      }
    }
    // Der heutige Tag ist immer der letzte Punkt, damit der aktuelle Saldo angezeigt wird.
    dates.add(end);
    return dates;
  }

  // Tage zwischen zwei Kalenderdaten, unabhängig von der Zeitumstellung.
  static int daysBetween(DateTime from, DateTime to) {
    return DateTime.utc(to.year, to.month, to.day).difference(DateTime.utc(from.year, from.month, from.day)).inDays;
  }

  static DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);
}
