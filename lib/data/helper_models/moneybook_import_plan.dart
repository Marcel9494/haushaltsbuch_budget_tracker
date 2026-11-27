import '../models/account.dart';
import '../models/booking.dart';
import '../models/budget.dart';
import '../models/category.dart';
import '../models/goal.dart';

// Ergebnis der Umwandlung einer Moneybook-Sicherung in die Datenstruktur dieser App.
// Alle neuen Datensätze haben bereits eine Id, damit Buchungen und Budgets vor dem
// Speichern auf ihre Konten, Kategorien und Ziele verweisen können.
class MoneybookImportPlan {
  final List<Account> newAccounts;
  final List<Category> newCategories;
  final List<Goal> newGoals;
  final List<Budget> budgets;
  final List<Booking> bookings;
  // Anzahl Moneybook-Einträge, die einem bereits vorhandenen Datensatz zugeordnet wurden.
  final int reusedAccounts;
  final int reusedCategories;
  final int reusedGoals;
  // Anzahl Moneybook-Einträge, die nicht übernommen werden konnten.
  final int skippedBookings;
  final int skippedBudgets;

  const MoneybookImportPlan({
    required this.newAccounts,
    required this.newCategories,
    required this.newGoals,
    required this.budgets,
    required this.bookings,
    required this.reusedAccounts,
    required this.reusedCategories,
    required this.reusedGoals,
    required this.skippedBookings,
    required this.skippedBudgets,
  });

  bool get hasNothingToImport =>
      newAccounts.isEmpty && newCategories.isEmpty && newGoals.isEmpty && budgets.isEmpty && bookings.isEmpty;
}
