import 'package:flutter_test/flutter_test.dart';
import 'package:haushaltsbuch_budget_tracker/core/utils/date_helper.dart';
import 'package:haushaltsbuch_budget_tracker/data/enums/repetition_type.dart';
import 'package:haushaltsbuch_budget_tracker/data/repositories/booking_repository.dart';

// Tests zu Issue #163: Buchungsdaten unabhängig von Zeitzone und Zeitumstellung.
// Für den Zeitumstellungs-Test die Tests am besten zusätzlich so ausführen:
//   TZ=Europe/Berlin flutter test test/booking_date_test.dart
void main() {
  String d(DateTime date) => toDateOnlyString(date);

  group('Datum speichern und laden', () {
    test('wird als reines Datum gespeichert', () {
      expect(toDateOnlyString(DateTime(2028, 3, 1)), '2028-03-01');
      expect(toDateOnlyString(DateTime(2026, 12, 31, 23, 59)), '2026-12-31');
    });

    test('reines Datum aus Supabase wird zum selben Kalendertag', () {
      final DateTime date = parseDateOnly('2028-03-01');
      expect([date.year, date.month, date.day, date.hour], [2028, 3, 1, 0]);
      expect(date.isUtc, isFalse);
    });

    test('Hin- und Rückweg ergeben denselben Tag', () {
      final DateTime original = DateTime(2028, 2, 29);
      expect(parseDateOnly(toDateOnlyString(original)), original);
    });
  });

  group('Monate addieren', () {
    test('begrenzt auf das Monatsende', () {
      expect(d(addMonthsClamped(DateTime(2026, 1, 31), 1)), '2026-02-28');
      expect(d(addMonthsClamped(DateTime(2028, 1, 31), 1)), '2028-02-29');
      expect(d(addMonthsClamped(DateTime(2026, 8, 31), 1)), '2026-09-30');
      expect(d(addMonthsClamped(DateTime(2026, 11, 30), 3)), '2027-02-28');
      expect(d(addMonthsClamped(DateTime(2028, 2, 29), 12)), '2029-02-28');
    });

    test('kehrt mit anchorDay zum ursprünglichen Tag zurück', () {
      expect(d(addMonthsClamped(DateTime(2026, 2, 28), 1, anchorDay: 31)), '2026-03-31');
    });
  });

  group('Wiederholungsserien', () {
    final BookingRepository repository = BookingRepository();

    List<String> firstDates(DateTime start, RepetitionType type, int count, {bool skipFirst = false}) =>
        repository.getRepetitionDates(start, type, skipFirst: skipFirst).take(count).map(d).toList();

    test('wöchentlich bleibt über die Zeitumstellung auf Montag', () {
      // Zeitumstellung am 25.10.2026 und 28.03.2027
      final List<DateTime> dates = repository.getRepetitionDates(DateTime(2026, 10, 19), RepetitionType.weekly);
      expect(dates.take(3).map(d).toList(), ['2026-10-19', '2026-10-26', '2026-11-02']);
      expect(dates.every((date) => date.weekday == DateTime.monday), isTrue);
      expect(dates.every((date) => date.hour == 0), isTrue);
    });

    test('zweiwöchentlich bleibt auf demselben Wochentag', () {
      final List<DateTime> dates = repository.getRepetitionDates(DateTime(2026, 10, 16), RepetitionType.twoWeekly);
      expect(dates.every((date) => date.weekday == DateTime.friday), isTrue);
      expect(dates.every((date) => date.hour == 0), isTrue);
    });

    test('monatlich ab dem 31. wandert nicht in den Folgemonat', () {
      expect(firstDates(DateTime(2026, 1, 31), RepetitionType.monthly, 5), [
        '2026-01-31',
        '2026-02-28',
        '2026-03-31',
        '2026-04-30',
        '2026-05-31',
      ]);
    });

    test('vierteljährlich und halbjährlich ab dem 31.', () {
      expect(firstDates(DateTime(2026, 8, 31), RepetitionType.quarterly, 4), ['2026-08-31', '2026-11-30', '2027-02-28', '2027-05-31']);
      expect(firstDates(DateTime(2026, 8, 31), RepetitionType.halfYearly, 3), ['2026-08-31', '2027-02-28', '2027-08-31']);
    });

    test('jährlich ab dem 29.02.', () {
      expect(firstDates(DateTime(2028, 2, 29), RepetitionType.yearly, 5), [
        '2028-02-29',
        '2029-02-28',
        '2030-02-28',
        '2031-02-28',
        '2032-02-29',
      ]);
    });

    test('Monatsanfang und Monatsende', () {
      expect(firstDates(DateTime(2026, 1, 1), RepetitionType.beginningOfMonth, 3), ['2026-01-01', '2026-02-01', '2026-03-01']);
      expect(firstDates(DateTime(2026, 1, 31), RepetitionType.endOfMonth, 3), ['2026-01-31', '2026-02-28', '2026-03-31']);
    });

    test('skipFirst überspringt die bestehende Buchung', () {
      expect(firstDates(DateTime(2026, 1, 31), RepetitionType.monthly, 2, skipFirst: true), ['2026-02-28', '2026-03-31']);
    });

    test('Serie läuft 5 Jahre', () {
      final List<DateTime> dates = repository.getRepetitionDates(DateTime(2026, 1, 15), RepetitionType.monthly);
      expect(dates.length, 60);
      expect(d(dates.last), '2030-12-15');
    });

    test('keine Wiederholung liefert nur das Startdatum', () {
      expect(firstDates(DateTime(2026, 10, 12), RepetitionType.noRepetition, 10), ['2026-10-12']);
    });
  });
}
