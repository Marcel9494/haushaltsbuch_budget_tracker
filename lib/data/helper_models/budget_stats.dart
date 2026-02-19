import 'package:fl_chart/fl_chart.dart';

class BudgetStats {
  final List<BarChartGroupData> barGroups;
  final List<double> usedAmounts;
  final List<double> totalBudgets;
  final double overallUsedAmount;
  final double overallBudgetAmount;

  const BudgetStats({
    required this.barGroups,
    required this.usedAmounts,
    required this.totalBudgets,
    required this.overallUsedAmount,
    required this.overallBudgetAmount,
  });
}
