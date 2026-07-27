import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:haushaltsbuch_budget_tracker/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../../../core/utils/currency_helper.dart';
import '../../../../../data/enums/goal_type.dart';
import '../../../../../data/models/booking.dart';
import '../../../../../data/models/goal.dart';

class GoalLineChart extends StatefulWidget {
  final Goal goal;
  final List<Booking> goalBookings;

  const GoalLineChart({
    super.key,
    required this.goal,
    required this.goalBookings,
  });

  @override
  State<GoalLineChart> createState() => _GoalLineChartState();
}

class _GoalLineChartState extends State<GoalLineChart> {
  List<Color> gradientColors = [
    Colors.cyanAccent,
    Colors.blue,
  ];
  List<Color> gradientColors2 = [
    Colors.redAccent,
    Colors.yellow,
  ];
  int totalDays = 0;

  @override
  void initState() {
    super.initState();
    totalDays = widget.goal.endDate.difference(widget.goal.startDate).inDays;
  }

  List<FlSpot> buildGoalLine() {
    final double goalValue = widget.goal.goalType == GoalType.payOff ? 0.0 : widget.goal.goalAmount.toDouble();

    return [
      FlSpot(0, goalValue),
      FlSpot(totalDays.toDouble(), goalValue),
    ];
  }

  List<FlSpot> buildIdealLine() {
    final spots = <FlSpot>[];

    for (int i = 0; i <= totalDays; i++) {
      final progress = i / totalDays;

      final value = widget.goal.goalType == GoalType.payOff ? widget.goal.goalAmount * (1 - progress) : widget.goal.goalAmount * progress;

      spots.add(FlSpot(i.toDouble(), value.toDouble()));
    }

    return spots;
  }

  List<FlSpot> buildCurrentProgressLine(List<Booking> bookings) {
    bookings.sort((a, b) => a.bookingDate.compareTo(b.bookingDate));
    final spots = <FlSpot>[];

    if (widget.goal.goalType == GoalType.payOff) {
      double remaining = widget.goal.goalAmount.toDouble();
      for (final booking in bookings) {
        final day = booking.bookingDate.difference(widget.goal.startDate).inDays.toDouble();
        remaining -= booking.amount;

        if (remaining < 0) {
          remaining = 0;
        }
        spots.add(FlSpot(day, remaining));
      }
    } else {
      double cumulative = 0;

      for (final booking in bookings) {
        final day = booking.bookingDate.difference(widget.goal.startDate).inDays.toDouble();
        cumulative += booking.amount;

        if (cumulative > widget.goal.goalAmount) {
          cumulative = widget.goal.goalAmount.toDouble();
        }
        spots.add(FlSpot(day, cumulative));
      }
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.8,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 12.0,
              top: 8.0,
              bottom: 8.0,
            ),
            child: LineChart(mainData()),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );

    final totalDays = widget.goal.endDate.difference(widget.goal.startDate).inDays;

    const int labelCount = 5;
    final step = totalDays / (labelCount - 1);

    // Prüfen ob value nahe an einem Schritt ist
    bool shouldShow = false;

    for (int i = 0; i < labelCount; i++) {
      if ((value - (i * step)).abs() < step / 2) {
        shouldShow = true;
        break;
      }
    }

    if (!shouldShow) {
      return const SizedBox.shrink();
    }

    final date = widget.goal.startDate.add(Duration(days: value.toInt()));

    // Format dynamisch je nach Dauer
    String text;
    if (totalDays > 365) {
      final month = DateFormat.MMM(Localizations.localeOf(context).toString()).format(date);
      final year = DateFormat.y(Localizations.localeOf(context).toString()).format(date);
      return SideTitleWidget(
        meta: meta,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              month,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              year,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    } else if (totalDays > 60) {
      text = DateFormat.MMM(Localizations.localeOf(context).toString()).format(date); // "Jan"
      return SideTitleWidget(
        meta: meta,
        child: Text(text, style: style),
      );
    } else {
      text = DateFormat('Md', Localizations.localeOf(context).languageCode).format(DateTime(date.year, date.month, value.toInt()));
      return SideTitleWidget(
        meta: meta,
        child: Text(text, style: style),
      );
    }
  }

  LineChartData mainData() {
    final t = AppLocalizations.of(context);
    return LineChartData(
      extraLinesData: ExtraLinesData(
        verticalLines: DateTime.now().isAfter(widget.goal.startDate) && DateTime.now().isBefore(widget.goal.endDate)
            ? [
                VerticalLine(
                  x: DateTime.now().difference(widget.goal.startDate).inDays.toDouble(),
                  color: Colors.orange.withAlpha(60),
                  strokeWidth: 2,
                  dashArray: [6, 4],
                  label: VerticalLineLabel(
                    show: true,
                    alignment: Alignment.topRight,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.orange.withAlpha(80),
                      fontWeight: FontWeight.bold,
                    ),
                    labelResolver: (_) => t.translate('today'),
                  ),
                ),
              ]
            : [],
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: widget.goal.goalAmount / 5,
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
            reservedSize: 40,
            interval: totalDays / 5,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 70.0,
            interval: widget.goal.goalAmount / 3,
            getTitlesWidget: (value, meta) {
              return Transform.rotate(
                angle: 0.28,
                child: Text(
                  CurrencyHelper.instance.formatCurrency(value, context, decimalDigits: 0),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: totalDays.toDouble(),
      minY: 0,
      maxY: widget.goal.goalAmount.toDouble(),
      lineBarsData: [
        // Aktueller Fortschritt
        LineChartBarData(
          spots: buildCurrentProgressLine(widget.goalBookings),
          isCurved: false,
          color: widget.goal.goalType == GoalType.payOff ? Colors.redAccent : Colors.green,
          barWidth: 3,
          dotData: FlDotData(show: true),
        ),

        // Ideal
        LineChartBarData(
          spots: buildIdealLine(),
          isCurved: false,
          color: widget.goal.goalType == GoalType.payOff ? Colors.orange : Colors.cyanAccent,
          dashArray: [10, 10], // gestrichelte Linie
          barWidth: 2,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                ColorTween(begin: gradientColors[0], end: gradientColors[1]).lerp(0.2)!.withValues(alpha: 0.05),
                ColorTween(begin: gradientColors[0], end: gradientColors[1]).lerp(0.2)!.withValues(alpha: 0.05),
              ],
            ),
          ),
        ),

        // Ziellinie schwarz / weiß
        LineChartBarData(
          spots: buildGoalLine(),
          isCurved: false,
          color: Colors.black,
          barWidth: 3,
          dotData: const FlDotData(show: false),
        ),
        LineChartBarData(
          spots: buildGoalLine(),
          isCurved: false,
          color: Colors.white,
          barWidth: 3,
          dashArray: [6, 6],
          dotData: const FlDotData(show: false),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final date = widget.goal.startDate.add(Duration(days: spot.x.toInt()));
              final formattedDate = '${date.day.toString().padLeft(2, '0')}.'
                  '${date.month.toString().padLeft(2, '0')}.'
                  '${date.year}';

              return LineTooltipItem(
                '$formattedDate\n${CurrencyHelper.instance.formatCurrency(spot.y, context)}',
                const TextStyle(color: Colors.white),
              );
            }).toList();
          },
        ),
      ),
    );
  }
}
