import 'package:collection/collection.dart';
import 'package:haushaltsbuch_budget_tracker/data/enums/budget_selection_type.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/consts/repeat_number_consts.dart';
import '../models/booking.dart';
import '../models/budget.dart';

class BudgetRepository {
  Future<void> createBudgets(Budget newBudget) async {
    // TODO hier noch auf doppelte Budgets prüfen, auch dort noch repetitionId mit beachten + update Methode.
    final budgetMap = <Map<String, dynamic>>[];
    DateTime currentBudgetDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
    final budgetId = const Uuid().v4();

    for (int i = 0; i < budgetRepetitionNumberInMonths; i++) {
      budgetMap.add({
        'budget_id': budgetId,
        'user_id': newBudget.userId,
        'category_id': newBudget.categoryId,
        'budget_date': DateFormat('yyyy-MM-dd').format(currentBudgetDate),
        'budget_amount': newBudget.budgetAmount,
      });

      currentBudgetDate = DateTime(
        currentBudgetDate.month == 12 ? currentBudgetDate.year + 1 : currentBudgetDate.year,
        currentBudgetDate.month == 12 ? 1 : currentBudgetDate.month + 1,
        1,
      );
    }
    await Supabase.instance.client.from('budgets').insert(budgetMap).select();
  }

  void updateBudget(Budget updatedBudget, BudgetSelectionType budgetSelectionType) async {
    final supabase = Supabase.instance.client;

    switch (budgetSelectionType) {
      case BudgetSelectionType.single:
        await supabase
            .from('budgets')
            .update({'budget_amount': updatedBudget.budgetAmount})
            .eq('id', updatedBudget.id!)
            .eq('user_id', supabase.auth.currentUser!.id)
            .eq('category_id', updatedBudget.categoryId);
        break;

      case BudgetSelectionType.onlyFuture:
        await supabase
            .from('budgets')
            .update({'budget_amount': updatedBudget.budgetAmount})
            .eq('user_id', supabase.auth.currentUser!.id)
            .eq('category_id', updatedBudget.categoryId)
            .gt('budget_date', DateFormat('yyyy-MM-dd').format(updatedBudget.budgetDate!));
        break;

      case BudgetSelectionType.all:
        await supabase
            .from('budgets')
            .update({'budget_amount': updatedBudget.budgetAmount})
            .eq('budget_id', updatedBudget.budgetId!)
            .eq('user_id', supabase.auth.currentUser!.id)
            .eq('category_id', updatedBudget.categoryId);
        break;
    }
  }

  Future<void> deleteBudget(Budget deleteBudget, BudgetSelectionType budgetSelectionType) async {
    final supabase = Supabase.instance.client;

    switch (budgetSelectionType) {
      case BudgetSelectionType.single:
        await supabase
            .from('budgets')
            .delete()
            .eq('id', deleteBudget.id!)
            .eq('user_id', supabase.auth.currentUser!.id)
            .eq('category_id', deleteBudget.categoryId);
        break;

      case BudgetSelectionType.onlyFuture:
        await supabase
            .from('budgets')
            .delete()
            .eq('user_id', supabase.auth.currentUser!.id)
            .eq('category_id', deleteBudget.categoryId)
            .gt('budget_date', DateFormat('yyyy-MM-dd').format(deleteBudget.budgetDate!));
        break;

      case BudgetSelectionType.all:
        await supabase
            .from('budgets')
            .delete()
            .eq('budget_id', deleteBudget.budgetId!)
            .eq('user_id', supabase.auth.currentUser!.id)
            .eq('category_id', deleteBudget.categoryId);
        break;
    }
  }

  Future<List<Budget>> loadMonthlyBudgets(DateTime selectedDate) async {
    final startOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final endOfMonth = DateTime(selectedDate.year, selectedDate.month + 1, 1);
    final monthlyBudgets = await Supabase.instance.client
        .from('budgets')
        .select('*, categories(*)')
        .gte('budget_date', startOfMonth)
        .lt('budget_date', endOfMonth)
        .order('budget_amount', ascending: false);
    return (monthlyBudgets as List).map((data) => Budget.fromMap(data)).toList();
  }

  Future<Map<String, List<Budget>>> loadYearlyBudgets(int selectedYear) async {
    final startOfYear = DateTime(selectedYear, 1, 1);
    final endOfYear = DateTime(selectedYear + 1, 1, 1);
    final yearlyBudgets = await Supabase.instance.client
        .from('budgets')
        .select('*, categories(*)')
        .gte('budget_date', startOfYear)
        .lt('budget_date', endOfYear)
        .order('budget_amount', ascending: false);
    final List<Budget> allBudgets = (yearlyBudgets as List).map((data) => Budget.fromMap(data)).toList();
    final Map<String, List<Budget>> budgetCategories = groupBy(allBudgets, (budget) {
      return budget.categoryId;
    });
    return budgetCategories;
  }

  Future<Map<String, List<Budget>>> loadYearlyBudgetsFromCategory(int selectedYear, String categoryId) async {
    final startOfYear = DateTime(selectedYear, 1, 1);
    final endOfYear = DateTime(selectedYear + 1, 1, 1);
    final yearlyBudgets = await Supabase.instance.client
        .from('budgets')
        .select('*, categories(*)')
        .gte('budget_date', startOfYear)
        .lt('budget_date', endOfYear)
        .eq('category_id', categoryId)
        .order('budget_date', ascending: false);
    final List<Budget> allBudgets = (yearlyBudgets as List).map((data) => Budget.fromMap(data)).toList();
    final Map<String, List<Budget>> budgetCategories = groupBy(allBudgets, (budget) {
      return budget.categoryId;
    });
    return budgetCategories;
  }

  double calculateUsedAmountForBudget(Budget budget, List<Booking> bookings) {
    double usedBudgetAmount = 0.0;
    for (Booking booking in bookings) {
      if (booking.categoryId == budget.categoryId &&
          booking.bookingDate.year == budget.budgetDate!.year &&
          booking.bookingDate.month == budget.budgetDate!.month) {
        usedBudgetAmount += booking.amount;
      }
    }
    return usedBudgetAmount;
  }

  double calculateMonthlyUsedAmount(List<Budget> budgets, List<Booking> bookings) {
    double usedOverallBudgetAmount = 0.0;
    for (Booking booking in bookings) {
      for (Budget budget in budgets) {
        if (booking.categoryId == budget.categoryId &&
            booking.bookingDate.year == budget.budgetDate!.year &&
            booking.bookingDate.month == budget.budgetDate!.month) {
          usedOverallBudgetAmount += booking.amount;
        }
      }
    }
    return usedOverallBudgetAmount;
  }

  double calculateOverallBudgetAmount(List<Budget> budgets) {
    double overallBudgetAmount = 0.0;
    for (Budget budget in budgets) {
      overallBudgetAmount += budget.budgetAmount;
    }
    return overallBudgetAmount;
  }

  double calculateOverallUsedBudgetPercent(double overallUsedBudgetAmount, double overallBudgetAmount) {
    if (overallBudgetAmount == 0) {
      return 0;
    }
    double overallUsedBudgetPercent = (overallUsedBudgetAmount / overallBudgetAmount) * 100;
    return overallUsedBudgetPercent;
  }
}
