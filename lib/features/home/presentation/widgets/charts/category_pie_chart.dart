import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:haushaltsbuch_budget_tracker/data/repositories/booking_repository.dart';
import 'package:haushaltsbuch_budget_tracker/l10n/app_localizations.dart';

import '../../../../../core/consts/animation_consts.dart';
import '../../../../../data/enums/period_of_time_type.dart';
import '../../../../../data/helper_models/booking_category_stats.dart';
import '../../../../../data/models/booking.dart';
import '../../../../bookings/data/enums/booking_type.dart';
import '../cards/category_stat_card.dart';

class CategoryStats extends StatefulWidget {
  final List<Booking> bookings;
  final DateTime currentSelectedDate;
  final PeriodOfTimeType currentPeriodOfTimeType;
  final ValueChanged<PeriodOfTimeType>? onPeriodOfTimeChanged;

  const CategoryStats({
    super.key,
    required this.bookings,
    required this.currentSelectedDate,
    required this.currentPeriodOfTimeType,
    required this.onPeriodOfTimeChanged,
  });

  @override
  State<CategoryStats> createState() => _CategoryStatsState();
}

class _CategoryStatsState extends State<CategoryStats> with TickerProviderStateMixin {
  final BookingRepository _bookingRepository = BookingRepository();
  int _touchedIndex = -1;
  List<BookingCategoryStats> _bookingCategoryStats = [];
  BookingType _selectedBookingType = BookingType.expense;
  final List<Color> _pieCategoryColors = [
    Colors.cyanAccent.shade700,
    Colors.blueAccent,
    Colors.purple,
    Colors.green,
    Colors.orange,
    Colors.redAccent,
    Colors.teal,
  ];

  @override
  void initState() {
    super.initState();
    _bookingCategoryStats = _bookingRepository.calculateMonthlyBookingsByCategory(widget.bookings, _selectedBookingType);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: SizedBox(
            width: double.infinity,
            child: SegmentedButton<BookingType>(
              segments: <ButtonSegment<BookingType>>[
                ButtonSegment<BookingType>(
                  value: BookingType.expense,
                  label: Text(t.translate('expenses')),
                  icon: Icon(Icons.remove_rounded),
                ),
                ButtonSegment<BookingType>(
                  value: BookingType.income,
                  label: Text(t.translate('revenue')),
                  icon: Icon(Icons.add_rounded),
                ),
              ],
              selected: <BookingType>{_selectedBookingType},
              onSelectionChanged: (Set<BookingType> newBookingTypeSelection) {
                setState(() {
                  _selectedBookingType = newBookingTypeSelection.first;
                });
                _bookingCategoryStats = _bookingRepository.calculateMonthlyBookingsByCategory(widget.bookings, _selectedBookingType);
              },
              showSelectedIcon: false,
              style: ButtonStyle(
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                ),
                backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Colors.cyanAccent.withAlpha(60);
                  }
                  return null;
                }),
              ),
            ),
          ),
        ),
        Card(
          child: AspectRatio(
            aspectRatio: 1.8,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.scale(
                            scale: value,
                            child: child,
                          ),
                        );
                      },
                      child: PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback: (FlTouchEvent event, pieTouchResponse) {
                              setState(() {
                                if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                                  _touchedIndex = -1;
                                  return;
                                }
                                _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                              });
                            },
                          ),
                          borderData: FlBorderData(show: false),
                          sectionsSpace: 6.0,
                          centerSpaceRadius: 40.0,
                          sections: showingSections(_bookingCategoryStats), // : showingSections(zeroStats(_bookingCategoryStats)),
                        ),
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeOutBack,
                      ),
                    ),
                  ),
                ),
                /*const Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Indicator(
                            color: Colors.cyanAccent,
                            text: 'First',
                            isSquare: true,
                          ),
                          SizedBox(height: 4),
                          Indicator(
                            color: Colors.blueAccent,
                            text: 'Second',
                            isSquare: true,
                          ),
                          SizedBox(height: 4),
                          Indicator(
                            color: Colors.purple,
                            text: 'Third',
                            isSquare: true,
                          ),
                          SizedBox(height: 4),
                          Indicator(
                            color: Colors.green,
                            text: 'Fourth',
                            isSquare: true,
                          ),
                          SizedBox(height: 18),
                        ],
                      ),
                      const SizedBox(width: 28),*/
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              AnimationLimiter(
                child: ListView.builder(
                  itemCount: _bookingCategoryStats.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: listAnimationDurationInMs),
                      child: CategoryStatCard(
                        bookingCategoryStats: _bookingCategoryStats[index],
                        pieCategoryColor: _pieCategoryColors[index],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 54.0),
            ],
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> showingSections(List<BookingCategoryStats> bookingCategoryStats) {
    return List.generate(bookingCategoryStats.length, (i) {
      final isTouched = i == _touchedIndex;
      final fontSize = isTouched ? 22.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      return PieChartSectionData(
        color: _pieCategoryColors[i % _pieCategoryColors.length],
        value: bookingCategoryStats[i].percentage,
        title: '${bookingCategoryStats[i].percentage.toStringAsFixed(1)}% ${bookingCategoryStats[i].category}',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: shadows,
        ),
      );
    });
  }

  List<BookingCategoryStats> zeroStats(
    List<BookingCategoryStats> stats,
  ) {
    return stats
        .map(
          (e) => BookingCategoryStats(
            category: e.category,
            totalAmount: 0,
            percentage: 0,
          ),
        )
        .toList();
  }
}
