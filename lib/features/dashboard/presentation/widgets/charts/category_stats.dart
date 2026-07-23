import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:haushaltsbuch_budget_tracker/data/repositories/booking_repository.dart';
import 'package:haushaltsbuch_budget_tracker/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../../../core/consts/animation_consts.dart';
import '../../../../../data/enums/booking_type.dart';
import '../../../../../data/enums/period_of_time_type.dart';
import '../../../../../data/helper_models/amount_type_stats.dart';
import '../../../../../data/helper_models/booking_category_stats.dart';
import '../../../../../data/models/booking.dart';
import '../cards/amount_type_card.dart';
import '../cards/category_stat_card.dart';

class CategoryStats extends StatefulWidget {
  final List<Booking> bookings;
  final DateTime currentSelectedDate;
  final PeriodOfTimeType currentPeriodOfTimeType;

  const CategoryStats({
    super.key,
    required this.bookings,
    required this.currentSelectedDate,
    required this.currentPeriodOfTimeType,
  });

  @override
  State<CategoryStats> createState() => _CategoryStatsState();
}

class _CategoryStatsState extends State<CategoryStats> with TickerProviderStateMixin {
  final BookingRepository _bookingRepository = BookingRepository();
  List<BookingCategoryStats> _bookingCategoryStats = [];
  List<AmountTypeStats> _amountTypeStats = [];
  BookingType _selectedBookingType = BookingType.expense;
  String _selectedAmountType = 'overall';
  final List<Color> _pieCategoryColors = [
    Colors.cyanAccent.shade700,
    Colors.blueAccent,
    Colors.purple,
    Colors.green,
    Colors.orange,
    Colors.redAccent,
    Colors.teal,
    Colors.indigo,
    Colors.amber.shade700,
    Colors.deepOrange,
  ];
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    setBookingCategoryState();
  }

  void setBookingCategoryState() {
    if (_selectedBookingType == BookingType.expense) {
      _amountTypeStats = _bookingRepository.calculateBookingsByExpensesAmountType(widget.bookings);
    } else {
      _amountTypeStats = _bookingRepository.calculateBookingsByIncomeAmountType(widget.bookings);
    }
    _bookingCategoryStats = _bookingRepository.calculateBookingsByCategory(widget.bookings, _selectedBookingType, _selectedAmountType);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: SegmentedButton<BookingType>(
                  segments: [
                    ButtonSegment(
                      value: BookingType.expense,
                      label: Text(t.translate('expenses')),
                      icon: Icon(Icons.remove_rounded),
                    ),
                    ButtonSegment(
                      value: BookingType.income,
                      label: Text(t.translate('revenue')),
                      icon: Icon(Icons.add_rounded),
                    ),
                  ],
                  selected: {_selectedBookingType},
                  onSelectionChanged: (newSelection) {
                    setState(() {
                      _selectedBookingType = newSelection.first;
                      _selectedAmountType = 'overall';
                    });
                    setBookingCategoryState();
                  },
                  showSelectedIcon: false,
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all(
                      const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      ),
                    ),
                    backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.cyanAccent.withAlpha(50);
                      }
                      return Colors.transparent;
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.0),
        Row(
          children: [
            for (final stats in _amountTypeStats)
              AmountTypeCard(
                amountTypeStats: stats,
                selected: _selectedAmountType == stats.name,
                onTap: () {
                  setState(() {
                    _selectedAmountType = stats.name;
                  });
                  setBookingCategoryState();
                },
              ),
          ],
        ),
        Card(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.0),
                  ],
                ),
              ),
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
                              sections: _bookingCategoryStats.isNotEmpty ? showingSections(_bookingCategoryStats) : showingEmptySections(),
                            ),
                            duration: const Duration(milliseconds: 1000),
                            curve: Curves.easeOutBack,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
                        pieCategoryColor: _pieCategoryColors[index % _pieCategoryColors.length],
                        bookings: widget.bookings,
                        currentSelectedDate: widget.currentSelectedDate,
                        currentPeriodOfTimeType: widget.currentPeriodOfTimeType,
                        bookingType: _selectedBookingType,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> showingSections(List<BookingCategoryStats> bookingCategoryStats) {
    final locale = Localizations.localeOf(context).toString();
    return List.generate(bookingCategoryStats.length, (i) {
      final isTouched = i == _touchedIndex;
      final fontSize = isTouched ? 20.0 : 15.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      return PieChartSectionData(
        color: _pieCategoryColors[i % _pieCategoryColors.length],
        value: bookingCategoryStats[i].percentage,
        title:
            '${NumberFormat('#,##0.0', locale).format(bookingCategoryStats[i].percentage)}% ${bookingCategoryStats[i].category == 'no_category' ? AppLocalizations.of(context).translate('no_category') : bookingCategoryStats[i].category}',
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

  List<PieChartSectionData> showingEmptySections() {
    final t = AppLocalizations.of(context);
    return List.generate(1, (i) {
      return PieChartSectionData(
        color: _pieCategoryColors[0],
        value: 100.0,
        title: t.translate('empty_bookings'),
        radius: 50.0,
        titleStyle: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      );
    });
  }
}
