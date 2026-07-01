import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../core/utils/currency_formatter.dart';
import '../../../../../core/utils/date_helper.dart';
import '../../../../../l10n/app_localizations.dart';

class BudgetBarChart extends StatefulWidget {
  final List<double> totalBudgets;
  final List<double> usedAmounts;
  final List<BarChartGroupData> barGroups;
  final int currentSelectedYear;

  const BudgetBarChart({
    super.key,
    required this.totalBudgets,
    required this.usedAmounts,
    required this.barGroups,
    required this.currentSelectedYear,
  });

  @override
  State<BudgetBarChart> createState() => _BudgetBarChartState();
}

class _BudgetBarChartState extends State<BudgetBarChart> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  double maxY = 0.0;

  @override
  void initState() {
    maxY = calculateMaxY(widget.barGroups);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
    super.initState();
  }

  double calculateMaxY(List<BarChartGroupData> groups) {
    double maxY = 0;
    for (final group in groups) {
      for (final rod in group.barRods) {
        if (rod.toY > maxY) {
          maxY = rod.toY;
        }
      }
    }
    return maxY * 1.1;
  }

  List<BarChartGroupData> getBarGroups() {
    final currentMonth = DateTime.now().month - 1;
    final currentYear = DateTime.now().year;
    return List.generate(12, (index) {
      final isCurrentYear = widget.currentSelectedYear == currentYear;
      final isFutureYear = widget.currentSelectedYear > currentYear;
      final isFutureMonth = isFutureYear || (isCurrentYear && index > currentMonth);

      const delayPerItem = 0.08;
      final start = index * delayPerItem;
      final end = start + (1 - delayPerItem * 12);
      double progress = 0.0;
      if (_animation.value < start) {
        progress = 0.0;
      } else if (_animation.value > end) {
        progress = 1.0;
      } else {
        progress = (_animation.value - start) / (end - start);
      }

      return BarChartGroupData(
        x: index,
        barsSpace: 4.0,
        barRods: [
          BarChartRodData(
            fromY: 0.0,
            toY: widget.totalBudgets[index] * progress,
            width: 6.0,
            color: isFutureMonth ? Colors.green.withValues(alpha: 0.6) : Colors.green,
            borderRadius: BorderRadius.circular(6),
          ),
          BarChartRodData(
            fromY: 0.0,
            toY: widget.usedAmounts[index] * progress,
            width: 6.0,
            color: isFutureMonth ? Colors.red.withValues(alpha: 0.6) : Colors.red,
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      );
    });
  }

  double getInterval() {
    double maxRevenue = 0.0;
    double maxExpenses = 0.0;
    if (widget.totalBudgets.isNotEmpty) {
      maxRevenue = widget.totalBudgets.reduce(max);
    }
    if (widget.usedAmounts.isNotEmpty) {
      maxExpenses = widget.usedAmounts.reduce(max);
    }
    final double maxValue = max(maxRevenue, maxExpenses);
    if (maxValue == 0.0) {
      return 1.0;
    }
    return maxValue / 3;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4.0, 6.0, 6.0, 14.0),
      child: SizedBox(
        height: 100.0,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return BarChart(
              BarChartData(
                barGroups: getBarGroups(),
                alignment: BarChartAlignment.spaceAround,
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final List<String> months = getAllShortMonthNames(Localizations.localeOf(context).toString());
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            months[value.toInt()],
                            style: const TextStyle(fontSize: 11.0, fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50.0,
                      interval: getInterval(),
                      getTitlesWidget: (value, meta) {
                        return Transform.rotate(
                          angle: 0.22,
                          child: Text(
                            formatCurrency(value, 'EUR', decimalDigits: 0),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  horizontalInterval: getInterval(),
                ),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(
                  enabled: true,
                  handleBuiltInTouches: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => Colors.grey.shade800,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final monthIndex = group.x.toInt();
                      final List<String> months = getAllMonthNames('de_DE');

                      return BarTooltipItem(
                        '${months[monthIndex]}:\n'
                        '${t.translate('budget')}: ${formatCurrency(widget.totalBudgets[monthIndex], 'EUR', decimalDigits: 2)}\n'
                        '${t.translate('consumed')}: ${formatCurrency(widget.usedAmounts[monthIndex], 'EUR', decimalDigits: 2)}\n'
                        '${t.translate('balance')}: ${formatCurrency(widget.totalBudgets[monthIndex] - widget.usedAmounts[monthIndex], 'EUR', decimalDigits: 2)}',
                        textAlign: TextAlign.start,
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 11.0,
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
