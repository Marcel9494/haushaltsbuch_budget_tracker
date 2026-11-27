import 'package:flutter_test/flutter_test.dart';
import 'package:haushaltsbuch_budget_tracker/core/utils/date_helper.dart';
import 'package:haushaltsbuch_budget_tracker/core/utils/moneybook_import_mapper.dart';
import 'package:haushaltsbuch_budget_tracker/core/utils/moneybook_value_parser.dart';
import 'package:haushaltsbuch_budget_tracker/data/enums/account_type.dart';
import 'package:haushaltsbuch_budget_tracker/data/enums/amount_type.dart';
import 'package:haushaltsbuch_budget_tracker/data/enums/booking_type.dart';
import 'package:haushaltsbuch_budget_tracker/data/enums/category_type.dart';
import 'package:haushaltsbuch_budget_tracker/data/enums/goal_type.dart';
import 'package:haushaltsbuch_budget_tracker/data/enums/repetition_type.dart';
import 'package:haushaltsbuch_budget_tracker/data/helper_models/existing_import_data.dart';
import 'package:haushaltsbuch_budget_tracker/data/helper_models/moneybook_import_plan.dart';
import 'package:haushaltsbuch_budget_tracker/data/models/booking.dart';
import 'package:haushaltsbuch_budget_tracker/data/models/moneybook_backup.dart';

// Tests zum Moneybook Import: Umwandlung einer Moneybook-Sicherung in die Datenstruktur der App.
void main() {
  Map<String, Object?> booking({
    int serieId = -1,
    String type = 'Ausgabe',
    String title = 'Einkauf',
    String date = '2026-01-15',
    String repetition = 'keine_wiederholung',
    double amount = 10.0,
    String amountType = 'variabel',
    String fromAccount = 'Geldbeutel',
    String toAccount = '',
    String categorie = 'Lebensmittel',
    int isBooked = 1,
    String goal = '',
  }) {
    return {
      'serieId': serieId,
      'type': type,
      'title': title,
      'date': date,
      'repetition': repetition,
      'amount': amount,
      'amountType': amountType,
      'currency': '€',
      'fromAccount': fromAccount,
      'toAccount': toAccount,
      'categorie': categorie,
      'isBooked': isBooked,
      'goal': goal,
    };
  }

  MoneybookImportPlan buildPlan({
    List<Map<String, Object?>> accountRows = const [],
    List<Map<String, Object?>> categoryRows = const [],
    List<Map<String, Object?>> bookingRows = const [],
    List<Map<String, Object?>> budgetRows = const [],
    List<Map<String, Object?>> goalRows = const [],
    ExistingImportData existingData = const ExistingImportData(),
  }) {
    int nextId = 0;
    return buildMoneybookImportPlan(
      backup: MoneybookBackup.fromRows(
        accountRows: accountRows,
        categoryRows: categoryRows,
        bookingRows: bookingRows,
        budgetRows: budgetRows,
        goalRows: goalRows,
      ),
      existingData: existingData,
      createId: () => 'id-${nextId++}',
      today: DateTime(2026, 11, 27),
    );
  }

  group('Werte aus der Sicherung lesen', () {
    test('Datum wird als reines Kalenderdatum gelesen', () {
      expect(readMoneybookDate('2026-05-19'), DateTime(2026, 5, 19));
      expect(readMoneybookDate('2026-05-19T13:45:00.000'), DateTime(2026, 5, 19));
      expect(readMoneybookDate(''), isNull);
      expect(readMoneybookDate('kein Datum'), isNull);
    });

    test('Zahlen und Wahrheitswerte werden tolerant gelesen', () {
      expect(readMoneybookDouble(5), 5.0);
      expect(readMoneybookDouble('12,5'), 12.5);
      expect(readMoneybookBool(1), isTrue);
      expect(readMoneybookBool(0), isFalse);
      expect(readMoneybookInt(null), -1);
    });
  });

  group('Moneybook-Werte zuordnen', () {
    test('Kontotypen', () {
      expect(mapMoneybookAccountType('konto'), AccountType.account);
      expect(mapMoneybookAccountType('bargeld'), AccountType.cash);
      expect(mapMoneybookAccountType('karte'), AccountType.card);
      expect(mapMoneybookAccountType('kapitalanlage'), AccountType.capitalInvestment);
      expect(mapMoneybookAccountType('versicherung'), AccountType.insurance);
      expect(mapMoneybookAccountType('kredit'), AccountType.credit);
      expect(mapMoneybookAccountType('kein_kontotyp_ausgewählt'), AccountType.other);
    });

    test('Buchungstypen, Investition wird zum Übertrag', () {
      expect(mapMoneybookBookingType('Ausgabe'), BookingType.expense);
      expect(mapMoneybookBookingType('Einnahme'), BookingType.income);
      expect(mapMoneybookBookingType('Übertrag'), BookingType.transfer);
      expect(mapMoneybookBookingType('Investition'), BookingType.transfer);
      expect(mapMoneybookBookingType(''), isNull);
    });

    test('Kategorietypen, Investitions-Kategorien werden nicht übernommen', () {
      expect(mapMoneybookCategoryType('Ausgabe'), CategoryType.expense);
      expect(mapMoneybookCategoryType('Einnahme'), CategoryType.income);
      expect(mapMoneybookCategoryType('Investition'), isNull);
    });

    test('Wiederholungen', () {
      expect(mapMoneybookRepetitionType('keine_wiederholung'), RepetitionType.noRepetition);
      expect(mapMoneybookRepetitionType('jede_woche'), RepetitionType.weekly);
      expect(mapMoneybookRepetitionType('alle_zwei_wochen'), RepetitionType.twoWeekly);
      expect(mapMoneybookRepetitionType('jeden_monat'), RepetitionType.monthly);
      expect(mapMoneybookRepetitionType('am_monatsanfang'), RepetitionType.beginningOfMonth);
      expect(mapMoneybookRepetitionType('Am Monatsende'), RepetitionType.endOfMonth);
      expect(mapMoneybookRepetitionType('alle_drei_monate'), RepetitionType.quarterly);
      expect(mapMoneybookRepetitionType('alle_sechs_monate'), RepetitionType.halfYearly);
      expect(mapMoneybookRepetitionType('jedes_jahr'), RepetitionType.yearly);
    });

    test('Betragstypen passend zum Buchungstyp', () {
      expect(mapMoneybookAmountType('fix', BookingType.expense), AmountType.fix);
      expect(mapMoneybookAmountType('variabel', BookingType.expense), AmountType.variable);
      expect(mapMoneybookAmountType('passiv', BookingType.income), AmountType.passive);
      expect(mapMoneybookAmountType('aktiv', BookingType.income), AmountType.active);
      expect(mapMoneybookAmountType('kauf', BookingType.transfer), AmountType.none);
      expect(mapMoneybookAmountType('undefiniert', BookingType.expense), AmountType.variable);
    });

    test('Beträge werden auf Cent gerundet', () {
      expect(roundImportAmount(84.13277098997398), 84.13);
      expect(roundImportAmount(-826.7152763157814), -826.72);
    });
  });

  group('Importplan erstellen', () {
    test('Konten werden übernommen oder wiederverwendet', () {
      final MoneybookImportPlan plan = buildPlan(
        accountRows: [
          {'id': 1, 'type': 'bargeld', 'name': 'Geldbeutel', 'amount': -826.7152763157814, 'currency': '€'},
          {'id': 2, 'type': 'konto', 'name': 'Girokonto', 'amount': 120.0, 'currency': '€'},
        ],
        existingData: const ExistingImportData(accountIdsByName: {'girokonto': 'existing-account'}),
      );

      expect(plan.newAccounts.length, 1);
      expect(plan.newAccounts.first.name, 'Geldbeutel');
      expect(plan.newAccounts.first.accountType, AccountType.cash);
      expect(plan.newAccounts.first.balance, -826.72);
      expect(plan.reusedAccounts, 1);
    });

    test('Serienbuchungen erhalten eine gemeinsame repetition_id', () {
      final MoneybookImportPlan plan = buildPlan(
        accountRows: [
          {'id': 1, 'type': 'bargeld', 'name': 'Geldbeutel', 'amount': 0.0, 'currency': '€'},
        ],
        bookingRows: [
          booking(serieId: 0, repetition: 'am_monatsanfang', date: '2026-01-01'),
          booking(serieId: 0, repetition: 'am_monatsanfang', date: '2026-02-01'),
          booking(serieId: 1, repetition: 'alle_drei_monate', date: '2026-01-03', isBooked: 0),
          booking(serieId: -1),
        ],
      );

      final List<Booking> bookings = plan.bookings;
      expect(bookings.length, 4);
      expect(bookings[0].repetitionId, isNotNull);
      expect(bookings[0].repetitionId, bookings[1].repetitionId);
      expect(bookings[2].repetitionId, isNot(bookings[0].repetitionId));
      expect(bookings[2].repetitionType, RepetitionType.quarterly);
      expect(bookings[2].isBooked, isFalse);
      expect(bookings[3].repetitionId, isNull);
      expect(bookings[3].repetitionType, RepetitionType.noRepetition);
      expect(toDateOnlyString(bookings[1].bookingDate), '2026-02-01');
    });

    test('Buchungen verweisen auf vorhandene oder neue Kategorien und Konten', () {
      final MoneybookImportPlan plan = buildPlan(
        accountRows: [
          {'id': 1, 'type': 'bargeld', 'name': 'Geldbeutel', 'amount': 0.0, 'currency': '€'},
        ],
        categoryRows: [
          {'id': 1, 'type': 'Ausgabe', 'name': 'Lebensmittel'},
          {'id': 2, 'type': 'Einnahme', 'name': 'Gehalt'},
          {'id': 3, 'type': 'Investition', 'name': 'ETFs'},
        ],
        bookingRows: [
          booking(categorie: 'Lebensmittel'),
          booking(type: 'Einnahme', categorie: 'Gehalt', amountType: 'passiv'),
          // Kategorie existiert nur noch in der Buchung
          booking(categorie: 'Haustier'),
          // Konto existiert nur noch in der Buchung
          booking(fromAccount: 'Altes Konto'),
        ],
        existingData: ExistingImportData(
          categoryIdsByKey: {importCategoryKey('lebensmittel', CategoryType.expense): 'existing-category'},
        ),
      );

      expect(plan.reusedCategories, 1);
      expect(plan.newCategories.map((category) => category.categoryName), ['Gehalt', 'Haustier']);
      expect(plan.bookings[0].categoryId, 'existing-category');
      expect(plan.bookings[1].bookingType, BookingType.income);
      expect(plan.bookings[1].amountType, AmountType.passive);
      expect(plan.bookings[1].categoryId, plan.newCategories[0].id);
      expect(plan.bookings[2].categoryId, plan.newCategories[1].id);
      expect(plan.newAccounts.map((account) => account.name), ['Geldbeutel', 'Altes Konto']);
      expect(plan.newAccounts[1].balance, 0.0);
      expect(plan.bookings[3].debitAccountId, plan.newAccounts[1].id);
    });

    test('Investitionen werden zu Überträgen, unvollständige Buchungen werden übersprungen', () {
      final MoneybookImportPlan plan = buildPlan(
        accountRows: [
          {'id': 1, 'type': 'konto', 'name': 'Girokonto', 'amount': 0.0, 'currency': '€'},
          {'id': 2, 'type': 'kapitalanlage', 'name': 'Aktiendepot', 'amount': 0.0, 'currency': '€'},
        ],
        bookingRows: [
          booking(type: 'Investition', title: '', amountType: 'kauf', fromAccount: 'Girokonto', toAccount: 'Aktiendepot', categorie: 'ETFs'),
          booking(type: 'Übertrag', fromAccount: 'Girokonto', toAccount: '', categorie: 'übertrag'),
          booking(date: 'ungültig'),
          booking(fromAccount: ''),
        ],
      );

      expect(plan.bookings.length, 1);
      expect(plan.skippedBookings, 3);
      final Booking investment = plan.bookings.first;
      expect(investment.bookingType, BookingType.transfer);
      expect(investment.amountType, AmountType.none);
      expect(investment.categoryId, isNull);
      expect(investment.title, 'ETFs');
      expect(investment.debitAccountId, plan.newAccounts[0].id);
      expect(investment.targetAccountId, plan.newAccounts[1].id);
    });

    test('Budgets werden auf den Monatsersten gelegt und als Serie pro Kategorie angelegt', () {
      final MoneybookImportPlan plan = buildPlan(
        categoryRows: [
          {'id': 1, 'type': 'Ausgabe', 'name': 'Lebensmittel'},
          {'id': 2, 'type': 'Ausgabe', 'name': 'Haushaltswaren'},
        ],
        budgetRows: [
          {'categorie': 'Lebensmittel', 'date': '2026-05-19', 'amount': 300.0},
          {'categorie': 'Lebensmittel', 'date': '2026-05-01', 'amount': 300.0},
          {'categorie': 'Lebensmittel', 'date': '2026-06-01', 'amount': 300.0},
          {'categorie': 'Haushaltswaren', 'date': '2026-06-01', 'amount': 50.0},
        ],
        existingData: ExistingImportData(
          categoryIdsByKey: {importCategoryKey('haushaltswaren', CategoryType.expense): 'existing-category'},
          budgetCategoryIds: const {'existing-category'},
        ),
      );

      // Doppelter Monat und Kategorie mit vorhandenem Budget werden übersprungen.
      expect(plan.budgets.length, 2);
      expect(plan.skippedBudgets, 2);
      expect(plan.budgets.map((budget) => toDateOnlyString(budget.budgetDate!)), ['2026-05-01', '2026-06-01']);
      expect(plan.budgets[0].budgetId, plan.budgets[1].budgetId);
      expect(plan.budgets[0].categoryId, plan.newCategories.first.id);
    });

    test('Ziele werden angelegt und mit Buchungen verknüpft', () {
      final MoneybookImportPlan plan = buildPlan(
        accountRows: [
          {'id': 1, 'type': 'konto', 'name': 'Girokonto', 'amount': 0.0, 'currency': '€'},
        ],
        goalRows: [
          {
            'id': 1,
            'name': 'Urlaub',
            'amount': 100.0,
            'goalAmount': 1500.0,
            'currency': '€',
            'startDate': '2026-01-01',
            'endDate': '2026-12-31',
            'type': 'Sparziel',
          },
        ],
        bookingRows: [
          booking(fromAccount: 'Girokonto', goal: 'Urlaub'),
          booking(fromAccount: 'Girokonto', goal: 'Kein Ziel'),
        ],
      );

      expect(plan.newGoals.length, 1);
      expect(plan.newGoals.first.goalType, GoalType.saving);
      expect(plan.newGoals.first.goalAmount, 1500.0);
      expect(plan.bookings[0].goalId, plan.newGoals.first.id);
      expect(plan.bookings[1].goalId, isNull);
    });

    test('Leere Sicherung ergibt nichts zum Importieren', () {
      expect(buildPlan().hasNothingToImport, isTrue);
    });
  });
}
