import 'package:flutter_test/flutter_test.dart';
import 'package:haushaltsbuch_budget_tracker/core/utils/net_worth_calculator.dart';
import 'package:haushaltsbuch_budget_tracker/data/enums/account_type.dart';
import 'package:haushaltsbuch_budget_tracker/data/enums/booking_type.dart';
import 'package:haushaltsbuch_budget_tracker/data/enums/net_worth_period_type.dart';
import 'package:haushaltsbuch_budget_tracker/data/helper_models/net_worth_booking.dart';
import 'package:haushaltsbuch_budget_tracker/data/models/account.dart';

void main() {
  final Account giro = Account(id: 'giro', name: 'Giro', accountType: AccountType.account, balance: 1000.0);
  final Account savings = Account(id: 'savings', name: 'Tagesgeld', accountType: AccountType.account, balance: 5000.0);
  final Account credit = Account(id: 'credit', name: 'Kredit', accountType: AccountType.credit, balance: -2000.0);

  double valueAt(List points, DateTime date) =>
      points.firstWhere((p) => p.date.year == date.year && p.date.month == date.month && p.date.day == date.day).netWorth;

  group('NetWorthCalculator.calculateHistory', () {
    test('letzter Punkt entspricht dem aktuellen Saldo der Kontoliste', () {
      final points = NetWorthCalculator.calculateHistory(
        accounts: [giro, savings, credit],
        bookings: const [],
        startDate: DateTime(2026, 9, 13),
        endDate: DateTime(2026, 10, 13),
      );
      expect(points.last.date, DateTime(2026, 10, 13));
      expect(points.last.netWorth, 4000.0);
      expect(points.first.netWorth, 4000.0);
    });

    test('Einnahmen und Ausgaben werden rückwärts herausgerechnet', () {
      final bookings = [
        NetWorthBooking(bookingType: BookingType.income, amount: 2500.0, bookingDate: DateTime(2026, 10, 1), debitAccountId: 'giro'),
        NetWorthBooking(bookingType: BookingType.expense, amount: 500.0, bookingDate: DateTime(2026, 10, 5), debitAccountId: 'giro'),
      ];
      final points = NetWorthCalculator.calculateHistory(
        accounts: [giro],
        bookings: bookings,
        startDate: DateTime(2026, 9, 28),
        endDate: DateTime(2026, 10, 13),
      );
      expect(valueAt(points, DateTime(2026, 10, 13)), 1000.0);
      expect(valueAt(points, DateTime(2026, 10, 5)), 1000.0); // Tagesende inkl. Ausgabe
      expect(valueAt(points, DateTime(2026, 10, 4)), 1500.0);
      expect(valueAt(points, DateTime(2026, 10, 1)), 1500.0);
      expect(valueAt(points, DateTime(2026, 9, 30)), -1000.0);
      expect(points.first.netWorth, -1000.0);
    });

    test('Überträge zwischen eigenen Konten ändern den Saldo nicht', () {
      final bookings = [
        NetWorthBooking(
          bookingType: BookingType.transfer,
          amount: 300.0,
          bookingDate: DateTime(2026, 10, 2),
          debitAccountId: 'giro',
          targetAccountId: 'savings',
        ),
      ];
      final points = NetWorthCalculator.calculateHistory(
        accounts: [giro, savings],
        bookings: bookings,
        startDate: DateTime(2026, 9, 28),
        endDate: DateTime(2026, 10, 13),
      );
      expect(points.every((p) => p.netWorth == 6000.0), isTrue);
    });

    test('Übertrag auf ein gelöschtes Konto zählt nur für das noch vorhandene Konto', () {
      final bookings = [
        NetWorthBooking(
          bookingType: BookingType.transfer,
          amount: 300.0,
          bookingDate: DateTime(2026, 10, 2),
          debitAccountId: 'giro',
          targetAccountId: 'deleted',
        ),
      ];
      final points = NetWorthCalculator.calculateHistory(
        accounts: [giro],
        bookings: bookings,
        startDate: DateTime(2026, 9, 28),
        endDate: DateTime(2026, 10, 13),
      );
      expect(points.first.netWorth, 1300.0);
      expect(points.last.netWorth, 1000.0);
    });

    test('nicht gebuchte und kontolose Buchungen werden ignoriert, Saldoanpassungen nicht', () {
      final bookings = [
        NetWorthBooking(
            bookingType: BookingType.expense, amount: 100.0, bookingDate: DateTime(2026, 10, 3), debitAccountId: 'giro', isBooked: false),
        NetWorthBooking(bookingType: BookingType.expense, amount: 50.0, bookingDate: DateTime(2026, 10, 3)),
        NetWorthBooking(bookingType: BookingType.income, amount: 200.0, bookingDate: DateTime(2026, 10, 3), isBalanceAdjustment: true),
      ];
      final points = NetWorthCalculator.calculateHistory(
        accounts: [giro],
        bookings: bookings,
        startDate: DateTime(2026, 9, 28),
        endDate: DateTime(2026, 10, 13),
      );
      expect(points.first.netWorth, 800.0);
      expect(points.last.netWorth, 1000.0);
    });

    test('Kreditkonten zählen wie auf der Kontoliste als Schulden', () {
      final Account positiveCredit = Account(id: 'credit', name: 'Kredit', accountType: AccountType.credit, balance: 2000.0);
      final points = NetWorthCalculator.calculateHistory(
        accounts: [giro, positiveCredit],
        bookings: const [],
        startDate: DateTime(2026, 9, 28),
        endDate: DateTime(2026, 10, 13),
      );
      expect(points.last.netWorth, -1000.0);
    });

    test('lange Zeiträume werden wöchentlich bzw. monatlich verdichtet', () {
      final daily = NetWorthCalculator.calculateHistory(
          accounts: [giro], bookings: const [], startDate: DateTime(2025, 10, 13), endDate: DateTime(2026, 10, 13));
      final weekly = NetWorthCalculator.calculateHistory(
          accounts: [giro], bookings: const [], startDate: DateTime(2023, 10, 13), endDate: DateTime(2026, 10, 13));
      final monthly = NetWorthCalculator.calculateHistory(
          accounts: [giro], bookings: const [], startDate: DateTime(2020, 10, 13), endDate: DateTime(2026, 10, 13));

      expect(daily.length, 366);
      expect(weekly.length, lessThan(170));
      expect(monthly.length, lessThan(80));
      for (final points in [daily, weekly, monthly]) {
        expect(points.first.date.isBefore(points.last.date), isTrue);
        expect(points.last.date, DateTime(2026, 10, 13));
        for (int i = 1; i < points.length; i++) {
          expect(points[i].date.isAfter(points[i - 1].date), isTrue);
        }
      }
    });
  });

  group('NetWorthPeriodType.getStartDate', () {
    final DateTime today = DateTime(2026, 10, 13, 21, 30);

    test('feste Zeiträume', () {
      expect(NetWorthPeriodType.oneMonth.getStartDate(today, null), DateTime(2026, 9, 13));
      expect(NetWorthPeriodType.oneYear.getStartDate(today, null), DateTime(2025, 10, 13));
      expect(NetWorthPeriodType.threeYears.getStartDate(today, null), DateTime(2023, 10, 13));
    });

    test('Max startet einen Tag vor der ersten Buchung', () {
      expect(NetWorthPeriodType.max.getStartDate(today, DateTime(2024, 3, 1)), DateTime(2024, 2, 29));
      expect(NetWorthPeriodType.max.getStartDate(today, DateTime(2026, 10, 10)), DateTime(2026, 9, 13));
    });
  });

  group('NetWorthBooking.fromMap', () {
    test('erkennt Saldoanpassungen am Titel ohne Konto', () {
      final booking = NetWorthBooking.fromMap({
        'booking_type': 'income',
        'amount': 150,
        'booking_date': '2026-10-01',
        'debit_account_id': null,
        'target_account_id': null,
        'category_id': null,
        'title': 'Saldoanpassung',
        'is_booked': true,
      }, balanceAdjustmentTitles: {'Saldoanpassung', 'Balance adjustment'});
      expect(booking.isBalanceAdjustment, isTrue);
      expect(booking.amount, 150.0);
      expect(booking.bookingDate, DateTime(2026, 10, 1));
    });
  });
}
