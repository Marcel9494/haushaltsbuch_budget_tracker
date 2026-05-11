import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:haushaltsbuch_budget_tracker/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../../../core/utils/currency_formatter.dart';
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
    return [
      FlSpot(0, widget.goal.goalAmount.toDouble()),
      FlSpot(totalDays.toDouble(), widget.goal.goalAmount.toDouble()),
    ];
  }

  List<FlSpot> buildIdealLine() {
    final spots = <FlSpot>[];

    for (int i = 0; i <= totalDays; i++) {
      final progress = i / totalDays;
      final value = progress * widget.goal.goalAmount;
      spots.add(FlSpot(i.toDouble(), value));
    }

    return spots;
  }

  List<FlSpot> buildCurrentProgressLine(List<Booking> goalBookings) {
    goalBookings.sort((a, b) => a.bookingDate.compareTo(b.bookingDate));

    double cumulative = 0.0;
    final spots = <FlSpot>[];

    for (final goalBooking in goalBookings) {
      final dayIndex = goalBooking.bookingDate.difference(widget.goal.startDate).inDays.toDouble();
      cumulative += goalBooking.amount;
      if (cumulative > widget.goal.goalAmount) {
        cumulative = widget.goal.goalAmount.toDouble();
      }
      spots.add(FlSpot(dayIndex, cumulative));
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
      final month = DateFormat.MMM('de_DE').format(date);
      final year = DateFormat.y('de_DE').format(date);
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
      text = DateFormat.MMM('de_DE').format(date); // "Jan"
      return SideTitleWidget(
        meta: meta,
        child: Text(text, style: style),
      );
    } else {
      text = DateFormat('dd.MM').format(date); // "12.01"
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
                  formatCurrency(value, 'EUR', decimalDigits: 0),
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
          color: Colors.green.shade500,
          barWidth: 3,
          dotData: FlDotData(show: true),
        ),

        // Ideal
        LineChartBarData(
          spots: buildIdealLine(),
          isCurved: false,
          color: Colors.cyanAccent,
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
                '$formattedDate\n${formatCurrency(spot.y, 'EUR')}',
                const TextStyle(color: Colors.white),
              );
            }).toList();
          },
        ),
      ),
    );
  }
}
