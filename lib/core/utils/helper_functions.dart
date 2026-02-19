import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../data/helper_models/budget_stats.dart';
import '../../data/models/booking.dart';
import '../../data/models/budget.dart';
import '../../data/repositories/budget_repository.dart';

BudgetStats calculateBudgetStats(Map<String, List<Budget>> budgets, List<Booking> bookings, int year) {
  final BudgetRepository _budgetRepository = BudgetRepository();

  final List<BarChartGroupData> barGroups = [];
  final List<double> usedAmounts = [];
  final List<double> totalBudgets = [];

  double overallUsedAmount = 0.0;
  double overallBudgetAmount = 0.0;

  for (int month = 1; month <= 12; month++) {
    final monthlyBudgets = budgets.values.expand((list) => list).where((b) => b.budgetDate?.year == year && b.budgetDate?.month == month).toList();
    final monthlyTotal = monthlyBudgets.fold(0.0, (sum, b) => sum + b.budgetAmount);

    totalBudgets.add(monthlyTotal);
    overallBudgetAmount += monthlyTotal;

    final monthlyUsed = _budgetRepository.calculateMonthlyUsedAmount(monthlyBudgets, bookings);

    usedAmounts.add(monthlyUsed);
    overallUsedAmount += monthlyUsed;

    barGroups.add(makeGroupData(month - 1, monthlyTotal, monthlyUsed));
  }

  return BudgetStats(
    barGroups: barGroups,
    usedAmounts: usedAmounts,
    totalBudgets: totalBudgets,
    overallUsedAmount: overallUsedAmount,
    overallBudgetAmount: overallBudgetAmount,
  );
}

BarChartGroupData makeGroupData(int x, double budgetAmount, double usedAmount) {
  return BarChartGroupData(
    barsSpace: 3.0,
    x: x,
    barRods: [
      BarChartRodData(
        toY: budgetAmount,
        width: 7.0,
        gradient: const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.cyan,
            Colors.cyanAccent,
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8.0),
          topRight: Radius.circular(8.0),
          bottomLeft: Radius.circular(2.0),
          bottomRight: Radius.circular(2.0),
        ),
      ),
      BarChartRodData(
        toY: usedAmount,
        width: 7.0,
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            usedAmount > budgetAmount ? Colors.red : Colors.green,
            usedAmount > budgetAmount ? Colors.redAccent.shade200 : Colors.greenAccent,
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8.0),
          topRight: Radius.circular(8.0),
          bottomLeft: Radius.circular(2.0),
          bottomRight: Radius.circular(2.0),
        ),
      ),
    ],
  );
}
