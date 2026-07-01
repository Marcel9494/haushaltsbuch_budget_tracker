import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:haushaltsbuch_budget_tracker/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../../../core/utils/currency_formatter.dart';
import '../../../../../data/enums/booking_type.dart';
import '../../../../../data/models/booking.dart';

class MonthlyLineChart extends StatefulWidget {
  final List<Booking> bookings;

  const MonthlyLineChart({
    super.key,
    required this.bookings,
  });

  @override
  State<MonthlyLineChart> createState() => _MonthlyLineChartState();
}

class _MonthlyLineChartState extends State<MonthlyLineChart> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;
  late final DateTime now;
  late final int daysInMonth;

  @override
  void initState() {
    super.initState();

    now = DateTime.now();
    daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    );

    _animationController.forward();
  }

  double getMaxY(List<FlSpot> spots) {
    return spots.map((e) => e.y).reduce(max);
  }

  double getMinY(List<FlSpot> spots) {
    return spots.map((e) => e.y).reduce(min);
  }

  (List<FlSpot>, List<FlSpot>) generateMonthlySpots() {
    final List<FlSpot> incomeSpots = [];
    final List<FlSpot> expenseSpots = [];

    for (int day = 1; day <= daysInMonth; day++) {
      final bookingsOfDay = widget.bookings.where((booking) {
        final date = booking.bookingDate;

        return date.year == now.year && date.month == now.month && date.day == day;
      }).toList();

      final incomeTotal = bookingsOfDay.where((b) => b.bookingType == BookingType.income).fold<double>(0, (sum, booking) => sum + booking.amount);
      final expenseTotal = bookingsOfDay.where((b) => b.bookingType == BookingType.expense).fold<double>(0, (sum, booking) => sum - booking.amount);

      incomeSpots.add(FlSpot(day.toDouble(), incomeTotal));
      expenseSpots.add(FlSpot(day.toDouble(), expenseTotal));
    }
    return (incomeSpots, expenseSpots);
  }

  List<FlSpot> animatedSpots(List<FlSpot> spots) {
    final visibleCount = (spots.length * _animation.value).floor();
    return spots.take(visibleCount.clamp(0, spots.length)).toList();
  }

  double getInterval(double minY, double maxY) {
    double interval = 0.0;
    if (minY.abs() <= maxY.abs()) {
      interval = maxY == 0 ? maxY.abs() : maxY.abs() / 2;
    } else {
      interval = minY == 0 ? minY.abs() : minY.abs() / 2;
    }
    return interval;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (incomeSpots, expenseSpots) = generateMonthlySpots();
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final animatedIncome = animatedSpots(incomeSpots);
        final animatedExpense = animatedSpots(expenseSpots);
        final allSpots = [
          ...incomeSpots,
          ...expenseSpots,
        ];
        final isEmptyChart = allSpots.every((spot) => spot.y == 0);

        final minY = isEmptyChart ? -100.0 : getMinY(allSpots);
        final maxY = isEmptyChart ? 100.0 : getMaxY(allSpots);
        return AspectRatio(
          aspectRatio: 2.0,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 18.0,
              left: 12.0,
              top: 24.0,
              bottom: 12.0,
            ),
            child: LineChart(
              mainData(
                animatedIncome,
                animatedExpense,
                minY,
                maxY,
              ),
            ),
          ),
        );
      },
    );
  }

  LineChartData mainData(
    List<FlSpot> incomeSpots,
    List<FlSpot> expenseSpots,
    double minY,
    double maxY,
  ) {
    final t = AppLocalizations.of(context);
    return LineChartData(
      minX: 1,
      maxX: daysInMonth.toDouble(),
      minY: minY,
      maxY: maxY,
      gridData: FlGridData(show: true),
      lineTouchData: LineTouchData(
        enabled: true,
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => Colors.grey.shade800,
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            if (touchedSpots.isEmpty) {
              return [];
            }

            final day = touchedSpots.first.x.toInt();
            final date = DateTime(now.year, now.month, day);
            final revenue = touchedSpots.firstWhere((s) => s.barIndex == 0).y;
            final expenses = touchedSpots.firstWhere((s) => s.barIndex == 1).y;

            return touchedSpots.map((spot) {
              if (spot.barIndex != 0) {
                return null;
              }

              return LineTooltipItem(
                '${DateFormat.yMEd(Localizations.localeOf(context).toString()).format(date)}:\n'
                '${t.translate('revenue')}: ${formatCurrency(revenue, 'EUR')}\n'
                '${t.translate('expenses')}: ${formatCurrency(expenses.abs(), 'EUR')}\n'
                '${t.translate('balance')}: ${formatCurrency(revenue - expenses.abs(), 'EUR')}',
                textAlign: TextAlign.start,
                const TextStyle(color: Colors.white, fontSize: 11.0),
              );
            }).toList();
          },
        ),
        getTouchedSpotIndicator: (barData, spotIndexes) {
          return spotIndexes.map((index) {
            return TouchedSpotIndicatorData(
              FlLine(color: Colors.white30),
              FlDotData(
                getDotPainter: (spot, percent, bar, index) {
                  return FlDotCirclePainter(
                    radius: 6.0,
                    color: barData.color == Colors.green ? Colors.green : Colors.red,
                  );
                },
              ),
            );
          }).toList();
        },
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 5,
            getTitlesWidget: (value, meta) {
              if (value.toInt() == 31) {
                return const SizedBox.shrink();
              }
              return SideTitleWidget(
                meta: meta,
                child: Text(
                  DateFormat('Md', Localizations.localeOf(context).languageCode).format(DateTime(now.year, now.month, value.toInt())),
                  style: const TextStyle(fontSize: 12.0),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 64.0,
            interval: getInterval(minY, maxY),
            getTitlesWidget: (value, meta) {
              return Transform.rotate(
                angle: 0.15,
                child: Text(
                  formatCurrency(value.abs(), 'EUR', decimalDigits: 0),
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
      lineBarsData: [
        LineChartBarData(
          spots: incomeSpots,
          isCurved: true,
          isStrokeCapRound: true,
          barWidth: 2.0,
          color: Colors.green,
          dotData: const FlDotData(show: false),
          aboveBarData: BarAreaData(
            show: true,
            color: Colors.green.withValues(alpha: 0.2),
          ),
        ),
        LineChartBarData(
          spots: expenseSpots,
          isCurved: true,
          isStrokeCapRound: true,
          barWidth: 2.0,
          color: Colors.red,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.red.withValues(alpha: 0.2),
          ),
        ),
      ],
    );
  }
}
