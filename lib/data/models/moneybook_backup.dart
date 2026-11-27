import 'moneybook_account.dart';
import 'moneybook_booking.dart';
import 'moneybook_budget.dart';
import 'moneybook_category.dart';
import 'moneybook_goal.dart';

// Gesamter Inhalt einer Moneybook-Sicherung (Moneybook_Backup.db).
class MoneybookBackup {
  final List<MoneybookAccount> accounts;
  final List<MoneybookCategory> categories;
  final List<MoneybookBooking> bookings;
  final List<MoneybookBudget> budgets;
  final List<MoneybookGoal> goals;

  const MoneybookBackup({
    required this.accounts,
    required this.categories,
    required this.bookings,
    required this.budgets,
    required this.goals,
  });

  factory MoneybookBackup.fromRows({
    required List<Map<String, Object?>> accountRows,
    required List<Map<String, Object?>> categoryRows,
    required List<Map<String, Object?>> bookingRows,
    required List<Map<String, Object?>> budgetRows,
    required List<Map<String, Object?>> goalRows,
  }) {
    return MoneybookBackup(
      accounts: accountRows.map(MoneybookAccount.fromMap).toList(),
      categories: categoryRows.map(MoneybookCategory.fromMap).toList(),
      bookings: bookingRows.map(MoneybookBooking.fromMap).toList(),
      budgets: budgetRows.map(MoneybookBudget.fromMap).toList(),
      goals: goalRows.map(MoneybookGoal.fromMap).toList(),
    );
  }
}
