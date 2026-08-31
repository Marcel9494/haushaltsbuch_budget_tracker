import 'dart:math' show max;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/utils/currency_helper.dart';
import '../../../../../data/enums/chart_filter_type.dart';
import '../../../../../data/models/booking.dart';
import '../../../../../data/repositories/booking_repository.dart';
import '../../../../../l10n/app_localizations.dart';
import '../buttons/chart_filter_segmented_button.dart';
import '../deco/chart_title.dart';

class MonthlyBarChart extends StatefulWidget {
  final Map<int, List<Booking>> bookings;
  final DateTime currentSelectedDate;

  const MonthlyBarChart({
    super.key,
    required this.bookings,
    required this.currentSelectedDate,
  });

  @override
  State<MonthlyBarChart> createState() => _MonthlyBarChartState();
}

class _MonthlyBarChartState extends State<MonthlyBarChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final BookingRepository _bookingRepository = BookingRepository();
  final List<double> _dailyRevenue = [];
  final List<double> _dailyExpenses = [];
  late final int _daysInMonth;
  ChartFilterType _selectedFilter = ChartFilterType.expenses;

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

    _daysInMonth = DateUtils.getDaysInMonth(
      widget.currentSelectedDate.year,
      widget.currentSelectedDate.month,
    );

    for (int day = 1; day <= _daysInMonth; day++) {
      final bookings = widget.bookings[day] ?? [];

      _dailyRevenue.add(
        _bookingRepository.calculateRevenue(bookings),
      );

      _dailyExpenses.add(
        _bookingRepository.calculateExpenses(bookings),
      );
    }
  }

  List<BarChartGroupData> getBarGroups() {
    final today = DateTime.now();
    final showRevenue = _selectedFilter == ChartFilterType.revenue || _selectedFilter == ChartFilterType.comparison;
    final showExpenses = _selectedFilter == ChartFilterType.expenses || _selectedFilter == ChartFilterType.comparison;

    return List.generate(_daysInMonth, (index) {
      final day = index + 1;

      final currentDate = DateTime(
        widget.currentSelectedDate.year,
        widget.currentSelectedDate.month,
        day,
      );

      const delayPerItem = 0.08;

      final start = index * delayPerItem / _daysInMonth * 12;
      final end = start + (1 - delayPerItem);

      double progress;

      if (_animation.value < start) {
        progress = 0.0;
      } else if (_animation.value > end) {
        progress = 1.0;
      } else {
        progress = (_animation.value - start) / (end - start);
      }

      progress = progress.clamp(0.0, 1.0);

      final rods = <BarChartRodData>[];

      if (showRevenue) {
        rods.add(
          BarChartRodData(
            fromY: 0,
            toY: _dailyRevenue[index] * progress,
            color: Colors.green,
            width: 6,
            borderRadius: BorderRadius.circular(6),
          ),
        );
      }

      if (showExpenses) {
        rods.add(
          BarChartRodData(
            fromY: 0,
            toY: _dailyExpenses[index] * progress,
            color: Colors.red,
            width: 6,
            borderRadius: BorderRadius.circular(6),
          ),
        );
      }

      return BarChartGroupData(
        x: index,
        barsSpace: 4,
        barRods: rods,
      );
    });
  }

  double getMaxY() {
    double maxRevenue = 0.0;
    double maxExpenses = 0.0;
    if (_dailyRevenue.isNotEmpty) {
      maxRevenue = _dailyRevenue.reduce(max);
    }
    if (_dailyExpenses.isNotEmpty) {
      maxExpenses = _dailyExpenses.reduce(max);
    }
    return max(maxRevenue, maxExpenses);
  }

  double getInterval() {
    final maxY = getMaxY();
    if (maxY == 0) {
      return 1;
    }
    return maxY / 3;
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
                              final day = value.toInt() + 1;

                              if ((day != 1 || day == 31) && day % 5 != 0) {
                                return const SizedBox.shrink();
                              }
                              String dateText = DateFormat('Md', Localizations.localeOf(context).languageCode)
                                  .format(DateTime(widget.currentSelectedDate.year, widget.currentSelectedDate.month, day));
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  dateText,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
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
                            final dayIndex = group.x.toInt();
                            final day = dayIndex + 1;

                            return BarTooltipItem(
                              '',
                              const TextStyle(
                                color: Colors.white,
                                fontSize: 11.0,
                              ),
                              textAlign: TextAlign.left,
                              children: [
                                TextSpan(
                                  text: '$day.${widget.currentSelectedDate.month}.${widget.currentSelectedDate.year}:\n',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: '● ',
                                  style: const TextStyle(color: Colors.green, fontSize: 14.0),
                                ),
                                TextSpan(
                                    text: '${t.translate('revenue')}: '
                                        '${CurrencyHelper.instance.formatCurrency(_dailyRevenue[dayIndex], context)}\n'),
                                TextSpan(
                                  text: '● ',
                                  style: const TextStyle(color: Colors.red, fontSize: 14.0),
                                ),
                                TextSpan(
                                    text: '${t.translate('expenses')}: '
                                        '${CurrencyHelper.instance.formatCurrency(_dailyExpenses[dayIndex], context)}\n'),
                                TextSpan(
                                  text: '● ',
                                  style: const TextStyle(color: Colors.cyanAccent, fontSize: 14.0),
                                ),
                                TextSpan(
                                  text: '${t.translate('balance')}: '
                                      '${CurrencyHelper.instance.formatCurrency(_dailyRevenue[dayIndex] - _dailyExpenses[dayIndex], context)}',
                                ),
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
