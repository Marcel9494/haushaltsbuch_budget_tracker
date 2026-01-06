import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../core/utils/currency_formatter.dart';
import '../../../../../l10n/app_localizations.dart';

class BudgetBarChart extends StatefulWidget {
  final List<double> totalBudgets;
  final List<double> usedAmounts;
  final List<BarChartGroupData> barGroups;

  const BudgetBarChart({
    super.key,
    required this.totalBudgets,
    required this.usedAmounts,
    required this.barGroups,
  });

  @override
  State<BudgetBarChart> createState() => _BudgetBarChartState();
}

class _BudgetBarChartState extends State<BudgetBarChart> {
  double maxY = 0.0;

  @override
  void initState() {
    maxY = calculateMaxY(widget.barGroups);
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

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Expanded(
      child: BarChart(
        BarChartData(
          maxY: maxY,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBorderRadius: BorderRadius.circular(8.0),
              tooltipPadding: const EdgeInsets.all(8),
              tooltipMargin: 8,
              getTooltipColor: (_) => Colors.black87,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${t.translate('budget')}: ${formatCurrency(widget.totalBudgets[groupIndex], 'EUR')}\n'
                  '${t.translate('consumed')}: ${formatCurrency(widget.usedAmounts[groupIndex], 'EUR')}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: bottomTitles,
                reservedSize: 36.0,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36.0,
                interval: 1,
                getTitlesWidget: (value, meta) => leftTitles(value, meta, maxY),
              ),
            ),
          ),
          borderData: FlBorderData(
            show: false,
          ),
          barGroups: widget.barGroups,
          gridData: const FlGridData(show: false),
        ),
      ),
    );
  }

  Widget leftTitles(double value, TitleMeta meta, double maxY) {
    const style = TextStyle(
      color: Color(0xff7589a2),
      fontWeight: FontWeight.bold,
      fontSize: 12.0,
    );
    String text;
    if (value == 0) {
      text = '0 €';
    } else if (value == maxY / 2) {
      text = '${(maxY / 2).toInt()} €';
    } else if (value == maxY) {
      text = '${maxY.toInt()} €';
    } else {
      return Container();
    }
    return SideTitleWidget(
      meta: meta,
      space: 0,
      child: Text(text, style: style),
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    final months = <String>['Jan', 'Feb', 'Mär', 'Apr', 'Mai', 'Jun', 'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez'];
    final Widget monthText = Text(
      months[value.toInt()],
      style: const TextStyle(
        color: Color(0xff7589a2),
        fontWeight: FontWeight.bold,
        fontSize: 12.0,
      ),
    );

    return SideTitleWidget(
      meta: meta,
      space: 12.0, // margin top
      child: monthText,
    );
  }
}
