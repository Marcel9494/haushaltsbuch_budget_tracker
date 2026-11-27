import '../../data/enums/account_type.dart';
import '../../data/enums/amount_type.dart';
import '../../data/enums/booking_type.dart';
import '../../data/enums/category_type.dart';
import '../../data/enums/goal_state_type.dart';
import '../../data/enums/goal_type.dart';
import '../../data/enums/repetition_type.dart';
import '../../data/helper_models/existing_import_data.dart';
import '../../data/helper_models/moneybook_import_plan.dart';
import '../../data/models/account.dart';
import '../../data/models/booking.dart';
import '../../data/models/budget.dart';
import '../../data/models/category.dart';
import '../../data/models/goal.dart';
import '../../data/models/moneybook_backup.dart';
import '../../data/models/moneybook_booking.dart';
import 'date_helper.dart';

// Wandelt eine Moneybook-Sicherung in die Datenstruktur dieser App um.
// Reine Funktionen ohne Datenbankzugriff, damit die Umwandlung testbar bleibt.

// Namen werden ohne Leerzeichen am Rand und ohne Groß-/Kleinschreibung verglichen,
// z.B. "Girokonto " und "girokonto" gelten als dasselbe Konto.
String normalizeImportName(String name) => name.trim().toLowerCase();

String importCategoryKey(String name, CategoryType categoryType) => '${categoryType.name}|${normalizeImportName(name)}';

// Beträge auf Cent runden, Moneybook speichert nach Währungsumrechnungen z.B. 84.13277098997398.
double roundImportAmount(double amount) => (amount * 100).roundToDouble() / 100;

AccountType mapMoneybookAccountType(String type) => switch (normalizeImportName(type)) {
      'konto' => AccountType.account,
      'kapitalanlage' => AccountType.capitalInvestment,
      'bargeld' => AccountType.cash,
      'karte' => AccountType.card,
      'versicherung' => AccountType.insurance,
      'kredit' => AccountType.credit,
      'sonstiges' => AccountType.other,
      _ => AccountType.other,
    };

// Investitionen gibt es in dieser App nicht. Sie verschieben in Moneybook Geld von einem
// Konto auf ein anderes und werden deshalb als Übertrag übernommen.
// Gibt null zurück, wenn die Buchung keinen gültigen Typ hat.
BookingType? mapMoneybookBookingType(String type) => switch (normalizeImportName(type)) {
      'ausgabe' => BookingType.expense,
      'einnahme' => BookingType.income,
      'übertrag' => BookingType.transfer,
      'investition' => BookingType.transfer,
      _ => null,
    };

bool isMoneybookInvestment(String type) => normalizeImportName(type) == 'investition';

// Investitions-Kategorien werden nicht übernommen (gibt null zurück).
CategoryType? mapMoneybookCategoryType(String type) => switch (normalizeImportName(type)) {
      'ausgabe' => CategoryType.expense,
      'einnahme' => CategoryType.income,
      _ => null,
    };

RepetitionType mapMoneybookRepetitionType(String repetition) => switch (normalizeImportName(repetition).replaceAll(' ', '_')) {
      'jede_woche' => RepetitionType.weekly,
      'alle_zwei_wochen' => RepetitionType.twoWeekly,
      'jeden_monat' => RepetitionType.monthly,
      'am_monatsanfang' => RepetitionType.beginningOfMonth,
      'am_monatsende' => RepetitionType.endOfMonth,
      'alle_drei_monate' => RepetitionType.quarterly,
      'alle_sechs_monate' => RepetitionType.halfYearly,
      'jedes_jahr' => RepetitionType.yearly,
      _ => RepetitionType.noRepetition,
    };

// Die App erlaubt bei Ausgaben nur variabel/fix, bei Einnahmen nur aktiv/passiv
// und bei Überträgen keinen Betragstyp.
AmountType mapMoneybookAmountType(String amountType, BookingType bookingType) {
  final String normalizedAmountType = normalizeImportName(amountType);
  return switch (bookingType) {
    BookingType.expense => normalizedAmountType == 'fix' ? AmountType.fix : AmountType.variable,
    BookingType.income => normalizedAmountType == 'passiv' ? AmountType.passive : AmountType.active,
    BookingType.transfer => AmountType.none,
  };
}

// Moneybook kennt Spar- und Ausgabenziele. Beide sammeln Geld für ein Ziel an und
// entsprechen damit am ehesten einem Sparziel dieser App.
GoalType mapMoneybookGoalType(String type) => GoalType.saving;

MoneybookImportPlan buildMoneybookImportPlan({
  required MoneybookBackup backup,
  required ExistingImportData existingData,
  required String Function() createId,
  required DateTime today,
}) {
  // ------------------------------------------------------------
  // Konten
  // ------------------------------------------------------------
  final Map<String, String> accountIds = {...existingData.accountIdsByName};
  final List<Account> newAccounts = [];
  final Set<String> importedAccountNames = {};
  int reusedAccounts = 0;

  for (final moneybookAccount in backup.accounts) {
    final String name = moneybookAccount.name.trim();
    final String key = normalizeImportName(name);
    if (name.isEmpty || !importedAccountNames.add(key)) {
      continue;
    }
    if (accountIds.containsKey(key)) {
      // Vorhandenes Konto wird verwendet, sein Kontostand bleibt unverändert.
      reusedAccounts++;
      continue;
    }
    final String id = createId();
    accountIds[key] = id;
    newAccounts.add(Account(
      id: id,
      name: name,
      accountType: mapMoneybookAccountType(moneybookAccount.type),
      balance: roundImportAmount(moneybookAccount.amount),
    ));
  }

  // Konten, die nur noch in Buchungen vorkommen (z.B. in Moneybook gelöscht), werden mit Kontostand 0 angelegt.
  String? resolveAccountId(String accountName) {
    final String name = accountName.trim();
    if (name.isEmpty) {
      return null;
    }
    final String key = normalizeImportName(name);
    final String? existingId = accountIds[key];
    if (existingId != null) {
      return existingId;
    }
    final String id = createId();
    accountIds[key] = id;
    newAccounts.add(Account(id: id, name: name, accountType: AccountType.other, balance: 0.0));
    return id;
  }

  // ------------------------------------------------------------
  // Kategorien
  // ------------------------------------------------------------
  final Map<String, String> categoryIds = {...existingData.categoryIdsByKey};
  final List<Category> newCategories = [];
  final Set<String> importedCategoryKeys = {};
  int reusedCategories = 0;

  for (final moneybookCategory in backup.categories) {
    final CategoryType? categoryType = mapMoneybookCategoryType(moneybookCategory.type);
    final String name = moneybookCategory.name.trim();
    if (categoryType == null || name.isEmpty) {
      continue;
    }
    final String key = importCategoryKey(name, categoryType);
    if (!importedCategoryKeys.add(key)) {
      continue;
    }
    if (categoryIds.containsKey(key)) {
      reusedCategories++;
      continue;
    }
    final String id = createId();
    categoryIds[key] = id;
    newCategories.add(Category(id: id, categoryName: name, categoryType: categoryType));
  }

  // Kategorien, die nur noch in Buchungen oder Budgets vorkommen, werden ebenfalls angelegt.
  String? resolveCategoryId(String categoryName, CategoryType categoryType) {
    final String name = categoryName.trim();
    if (name.isEmpty) {
      return null;
    }
    final String key = importCategoryKey(name, categoryType);
    final String? existingId = categoryIds[key];
    if (existingId != null) {
      return existingId;
    }
    final String id = createId();
    categoryIds[key] = id;
    newCategories.add(Category(id: id, categoryName: name, categoryType: categoryType));
    return id;
  }

  // ------------------------------------------------------------
  // Ziele
  // ------------------------------------------------------------
  final Map<String, String> goalIds = {...existingData.activeGoalIdsByName};
  final List<Goal> newGoals = [];
  final Set<String> importedGoalNames = {};
  int reusedGoals = 0;
  final DateTime todayDate = DateTime(today.year, today.month, today.day);

  for (final moneybookGoal in backup.goals) {
    final String name = moneybookGoal.name.trim();
    final String key = normalizeImportName(name);
    if (name.isEmpty || !importedGoalNames.add(key)) {
      continue;
    }
    if (goalIds.containsKey(key)) {
      reusedGoals++;
      continue;
    }
    final DateTime startDate = moneybookGoal.startDate ?? todayDate;
    final DateTime endDate = moneybookGoal.endDate ?? startDate;
    final String id = createId();
    goalIds[key] = id;
    newGoals.add(Goal(
      id: id,
      goalName: name,
      // Der aktuelle Stand eines Ziels wird in dieser App aus den verknüpften Buchungen berechnet.
      currentAmount: 0.0,
      goalAmount: roundImportAmount(moneybookGoal.goalAmount),
      goalType: mapMoneybookGoalType(moneybookGoal.type),
      goalState: GoalStateType.active,
      startDate: startDate,
      endDate: endDate.isBefore(startDate) ? startDate : endDate,
    ));
  }

  // "Kein Ziel" oder ein leerer Wert finden kein Ziel und ergeben damit null.
  String? resolveGoalId(String goalName) {
    final String name = goalName.trim();
    if (name.isEmpty) {
      return null;
    }
    return goalIds[normalizeImportName(name)];
  }

  // ------------------------------------------------------------
  // Budgets
  // ------------------------------------------------------------
  // Moneybook speichert pro Kategorie und Monat einen Eintrag. In dieser App gehören alle Monate
  // einer Kategorie zu einer Budget-Serie (budget_id) und das Budgetdatum ist immer der Monatserste.
  final List<Budget> budgets = [];
  final Map<String, String> budgetSeriesIds = {};
  final Set<String> importedBudgetMonths = {};
  int skippedBudgets = 0;

  for (final moneybookBudget in backup.budgets) {
    final DateTime? date = moneybookBudget.date;
    if (date == null) {
      skippedBudgets++;
      continue;
    }
    final String? categoryId = resolveCategoryId(moneybookBudget.categorie, CategoryType.expense);
    if (categoryId == null || existingData.budgetCategoryIds.contains(categoryId)) {
      // Für Kategorien mit vorhandenem Budget werden keine weiteren Budgets angelegt.
      skippedBudgets++;
      continue;
    }
    final DateTime budgetDate = DateTime(date.year, date.month, 1);
    if (!importedBudgetMonths.add('$categoryId|${toDateOnlyString(budgetDate)}')) {
      // Pro Kategorie ist nur ein Budget je Monat erlaubt.
      skippedBudgets++;
      continue;
    }
    budgets.add(Budget(
      id: createId(),
      budgetId: budgetSeriesIds.putIfAbsent(categoryId, createId),
      categoryId: categoryId,
      budgetAmount: roundImportAmount(moneybookBudget.amount),
      budgetDate: budgetDate,
    ));
  }

  // ------------------------------------------------------------
  // Buchungen
  // ------------------------------------------------------------
  final List<Booking> bookings = [];
  final Map<int, String> repetitionIds = {};
  int skippedBookings = 0;

  for (final MoneybookBooking moneybookBooking in backup.bookings) {
    final BookingType? bookingType = mapMoneybookBookingType(moneybookBooking.type);
    final DateTime? bookingDate = moneybookBooking.date;
    if (bookingType == null || bookingDate == null) {
      skippedBookings++;
      continue;
    }

    String? categoryId;
    String? targetAccountId;
    final String? debitAccountId = resolveAccountId(moneybookBooking.fromAccount);
    if (debitAccountId == null) {
      skippedBookings++;
      continue;
    }
    if (bookingType == BookingType.transfer) {
      targetAccountId = resolveAccountId(moneybookBooking.toAccount);
      if (targetAccountId == null || targetAccountId == debitAccountId) {
        skippedBookings++;
        continue;
      }
    } else {
      final CategoryType categoryType = bookingType == BookingType.income ? CategoryType.income : CategoryType.expense;
      categoryId = resolveCategoryId(moneybookBooking.categorie, categoryType);
    }

    final RepetitionType repetitionType = mapMoneybookRepetitionType(moneybookBooking.repetition);
    // Moneybook hat alle Termine einer Serie bereits als eigene Buchungen gespeichert.
    // Sie werden einzeln übernommen und über eine gemeinsame repetition_id zur Serie verbunden.
    final String? repetitionId = repetitionType != RepetitionType.noRepetition && moneybookBooking.serieId >= 0
        ? repetitionIds.putIfAbsent(moneybookBooking.serieId, createId)
        : null;

    String title = moneybookBooking.title.trim();
    if (title.isEmpty && isMoneybookInvestment(moneybookBooking.type)) {
      // Bei Investitionen geht die Kategorie (z.B. "ETFs") verloren, daher wird sie als Titel verwendet.
      title = moneybookBooking.categorie.trim();
    }

    bookings.add(Booking(
      id: createId(),
      bookingType: bookingType,
      title: title,
      amount: roundImportAmount(moneybookBooking.amount.abs()),
      amountType: mapMoneybookAmountType(moneybookBooking.amountType, bookingType),
      bookingDate: bookingDate,
      repetitionType: repetitionType,
      repetitionId: repetitionId,
      categoryId: categoryId,
      debitAccountId: debitAccountId,
      targetAccountId: targetAccountId,
      goalId: resolveGoalId(moneybookBooking.goal),
      // Moneybook-Kontostände enthalten nur gebuchte Buchungen. Nicht gebuchte Buchungen werden
      // von der App gebucht, sobald ihr Datum erreicht ist, und passen dann den Kontostand an.
      isBooked: moneybookBooking.isBooked,
    ));
  }

  return MoneybookImportPlan(
    newAccounts: newAccounts,
    newCategories: newCategories,
    newGoals: newGoals,
    budgets: budgets,
    bookings: bookings,
    reusedAccounts: reusedAccounts,
    reusedCategories: reusedCategories,
    reusedGoals: reusedGoals,
    skippedBookings: skippedBookings,
    skippedBudgets: skippedBudgets,
  );
}
