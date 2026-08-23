import 'dart:math' show max;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../core/utils/currency_helper.dart';
import '../../../../../core/utils/date_helper.dart';
import '../../../../../data/enums/chart_filter_type.dart';
import '../../../../../data/models/booking.dart';
import '../../../../../data/repositories/booking_repository.dart';
import '../../../../../l10n/app_localizations.dart';
import '../buttons/chart_filter_segmented_button.dart';
import '../deco/chart_title.dart';

class YearlyBarChart extends StatefulWidget {
  final Map<int, List<Booking>> bookings;
  final int currentSelectedYear;

  const YearlyBarChart({
    super.key,
    required this.bookings,
    required this.currentSelectedYear,
  });

  @override
  State<YearlyBarChart> createState() => _YearlyBarChartState();
}

class _YearlyBarChartState extends State<YearlyBarChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final BookingRepository _bookingRepository = BookingRepository();
  final List<double> _monthlyRevenue = [];
  final List<double> _monthlyExpenses = [];
  ChartFilterType _selectedFilter = ChartFilterType.comparison;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();

    for (int i = 0; i < 12; i++) {
      final month = i + 1;
      _monthlyRevenue.add(_bookingRepository.calculateRevenue(widget.bookings[month] ?? []));
      _monthlyExpenses.add(_bookingRepository.calculateExpenses(widget.bookings[month] ?? []));
    }
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

      double progress;

      if (_animation.value < start) {
        progress = 0.0;
      } else if (_animation.value > end) {
        progress = 1.0;
      } else {
        progress = (_animation.value - start) / (end - start);
      }

      final List<BarChartRodData> rods = [];

      switch (_selectedFilter) {
        case ChartFilterType.revenue:
          rods.add(
            BarChartRodData(
              fromY: 0,
              toY: _monthlyRevenue[index] * progress,
              width: 6,
              color: isFutureMonth ? Colors.green.withValues(alpha: 0.6) : Colors.green,
              borderRadius: BorderRadius.circular(6),
            ),
          );
          break;

        case ChartFilterType.expenses:
          rods.add(
            BarChartRodData(
              fromY: 0,
              toY: _monthlyExpenses[index] * progress,
              width: 6,
              color: isFutureMonth ? Colors.red.withValues(alpha: 0.6) : Colors.red,
              borderRadius: BorderRadius.circular(6),
            ),
          );
          break;

        case ChartFilterType.comparison:
          rods.addAll([
            BarChartRodData(
              fromY: 0,
              toY: _monthlyRevenue[index] * progress,
              width: 6,
              color: isFutureMonth ? Colors.green.withValues(alpha: 0.6) : Colors.green,
              borderRadius: BorderRadius.circular(6),
            ),
            BarChartRodData(
              fromY: 0,
              toY: _monthlyExpenses[index] * progress,
              width: 6,
              color: isFutureMonth ? Colors.red.withValues(alpha: 0.6) : Colors.red,
              borderRadius: BorderRadius.circular(6),
            ),
          ]);
          break;
      }

      return BarChartGroupData(
        x: index,
        barsSpace: 4,
        barRods: rods,
      );
    });
  }

  double getInterval() {
    double maxRevenue = 0.0;
    double maxExpenses = 0.0;
    if (_monthlyRevenue.isNotEmpty) {
      maxRevenue = _monthlyRevenue.reduce(max);
    }
    if (_monthlyExpenses.isNotEmpty) {
      maxExpenses = _monthlyExpenses.reduce(max);
    }
    final double maxValue = max(maxRevenue, maxExpenses);
    if (maxValue == 0.0) {
      return 1.0;
    }
    return maxValue / 3;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4.0, 16.0, 16.0, 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ChartTitle(
                  leftPadding: 12.0,
                  selectedChartFilter: _selectedFilter,
                ),
                ChartFilter(
                  selectedChartFilter: _selectedFilter,
                  onChanged: (filter) {
                    setState(() {
                      _selectedFilter = filter;
                    });
                    _controller.forward(from: 0);
                  },
                ),
              ],
            ),
            SizedBox(height: 32.0),
            SizedBox(
              height: 150.0,
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
                            reservedSize: 76.0,
                            interval: getInterval(),
                            getTitlesWidget: (value, meta) {
                              return Transform.rotate(
                                angle: 0.22,
                                child: Text(
                                  CurrencyHelper.instance.formatCurrency(value, context, decimalDigits: 0),
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
                      gridData: FlGridData(show: true),
                      borderData: FlBorderData(show: false),
                      barTouchData: BarTouchData(
                        enabled: true,
                        handleBuiltInTouches: true,
                        touchTooltipData: BarTouchTooltipData(
                          fitInsideHorizontally: true,
                          fitInsideVertically: true,
                          getTooltipColor: (_) => Colors.grey.shade800,
                          tooltipPadding: const EdgeInsets.symmetric(
                            horizontal: 14.0,
                            vertical: 10.0,
                          ),
                          maxContentWidth: 240.0,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final monthIndex = group.x.toInt();
                            final List<String> months = getAllMonthNames(Localizations.localeOf(context).toString());

                            final revenue = CurrencyHelper.instance.formatCurrency(_monthlyRevenue[monthIndex], context);
                            final expenses = CurrencyHelper.instance.formatCurrency(_monthlyExpenses[monthIndex], context);
                            final balance =
                                CurrencyHelper.instance.formatCurrency(_monthlyRevenue[monthIndex] - _monthlyExpenses[monthIndex], context);

                            return BarTooltipItem(
                              '',
                              const TextStyle(
                                color: Colors.white,
                                fontSize: 11.0,
                              ),
                              textAlign: TextAlign.left,
                              children: [
                                TextSpan(
                                  text: '${months[monthIndex]}:\n',
                                  style: const TextStyle(color: Colors.white, fontSize: 11.0, fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: '● ',
                                  style: const TextStyle(color: Colors.green, fontSize: 14.0),
                                ),
                                TextSpan(text: '${t.translate('revenue')}: $revenue\n'),
                                TextSpan(
                                  text: '● ',
                                  style: const TextStyle(color: Colors.red, fontSize: 14.0),
                                ),
                                TextSpan(text: '${t.translate('expenses')}: $expenses\n'),
                                TextSpan(
                                  text: '● ',
                                  style: const TextStyle(color: Colors.cyanAccent, fontSize: 14.0),
                                ),
                                TextSpan(text: '${t.translate('balance')}: $balance'),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
