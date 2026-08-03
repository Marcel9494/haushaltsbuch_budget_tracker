import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haushaltsbuch_budget_tracker/data/enums/period_of_time_type.dart';
import 'package:haushaltsbuch_budget_tracker/features/bookings/presentation/widgets/charts/monthly_bar_chart.dart';
import 'package:haushaltsbuch_budget_tracker/features/shared/presentation/widgets/deco/error_text.dart';

import '../../../../../blocs/booking/booking_bloc.dart';
import '../../../../../core/consts/animation_consts.dart';
import '../../../../../core/consts/route_consts.dart';
import '../../../../../core/page_arguments/home_page_arguments.dart';
import '../../../../../core/utils/date_helper.dart';
import '../../../../../data/enums/booking_type.dart';
import '../../../../../data/models/booking.dart';
import '../../../../../data/repositories/account_repository.dart';
import '../../../../../data/repositories/booking_repository.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../shared/presentation/widgets/deco/circular_loading_indicator.dart';
import '../../../../shared/presentation/widgets/deco/empty_list.dart';
import '../cards/booking_card.dart';
import '../deco/booking_list_daily_header.dart';
import '../deco/booking_list_overview.dart';

class MonthlyBookingList extends StatefulWidget {
  final DateTime currentSelectedDate;
  bool showBookingChart;
  bool showUpcomingBookings;
  final ValueChanged<bool>? onShowBookingChartChanged;
  final ValueChanged<bool>? onShowUpcomingBookingsChanged;
  PeriodOfTimeType currentPeriodOfTimeType;

  MonthlyBookingList({
    super.key,
    required this.currentSelectedDate,
    required this.showBookingChart,
    required this.onShowBookingChartChanged,
    required this.showUpcomingBookings,
    required this.onShowUpcomingBookingsChanged,
    required this.currentPeriodOfTimeType,
  });

  @override
  State<MonthlyBookingList> createState() => _MonthlyBookingListState();
}

class _MonthlyBookingListState extends State<MonthlyBookingList> {
  final ScrollController _scrollController = ScrollController();
  List<Booking> _pastBookings = [];
  List<Booking> _upcomingBookings = [];
  List<Booking> _combinedBookings = [];
  List<BarChartRodStackItem> incomeStack = [];
  List<BarChartRodStackItem> expenseStack = [];
  Map<String, double> incomeMap = {};
  Map<String, double> expenseMap = {};
  int _pastStartIndex = 0;
  double incomeTotal = 0;
  double expenseTotal = 0;
  final incomeColors = [
    Colors.green.shade800,
    Colors.green.shade600,
    Colors.green.shade500,
    Colors.green.shade300,
    Colors.green.shade200,
  ];

  final expenseColors = [
    Colors.red.shade800,
    Colors.red.shade600,
    Colors.red.shade500,
    Colors.red.shade300,
    Colors.red.shade200,
  ];

  void _prepareBookingList(List<Booking> bookings) {
    _pastBookings = bookings.where((b) => b.bookingDate.isBefore(DateTime.now())).toList()..sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
    _upcomingBookings = bookings.where((b) => b.bookingDate.isAfter(DateTime.now())).toList()..sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
    _pastStartIndex = widget.showUpcomingBookings ? _upcomingBookings.length : 0;
    _combinedBookings = [
      if (widget.showUpcomingBookings) ..._upcomingBookings,
      ..._pastBookings,
    ];
  }

  void _prepareBarChartData(List<Booking> bookings) {
    final t = AppLocalizations.of(context);
    incomeMap = {};
    expenseMap = {};

    for (Booking booking in bookings) {
      final categoryName = booking.category?.categoryName;
      final bookingType = booking.bookingType.name;
      final amount = booking.amount;

      if (bookingType == BookingType.income.name) {
        if (categoryName == null) {
          incomeMap[t.translate('no_category')] = (incomeMap[t.translate('no_category')] ?? 0) + amount;
        } else {
          incomeMap[categoryName] = (incomeMap[categoryName] ?? 0) + amount;
        }
      } else if (bookingType == BookingType.expense.name) {
        if (categoryName == null) {
          expenseMap[t.translate('no_category')] = (expenseMap[t.translate('no_category')] ?? 0) + amount;
        } else {
          expenseMap[categoryName] = (expenseMap[categoryName] ?? 0) + amount;
        }
      }
    }

    incomeMap = Map.fromEntries(
      incomeMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );

    expenseMap = Map.fromEntries(
      expenseMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );

    incomeStack = buildStackItems(incomeMap, incomeColors);
    expenseStack = buildStackItems(expenseMap, expenseColors);

    incomeTotal = incomeMap.values.fold(0, (a, b) => a + b);
    expenseTotal = expenseMap.values.fold(0, (a, b) => a + b);
  }

  List<BarChartRodStackItem> buildStackItems(
    Map<String, double> data,
    List<Color> colors,
  ) {
    double current = 0;
    int i = 0;

    return data.entries.map((entry) {
      final value = entry.value;
      final item = BarChartRodStackItem(
        current,
        current + value,
        colors[i % colors.length],
      );
      current += value;
      i++;
      return item;
    }).toList();
  }

  List<BarChartGroupData> getBarChartData(List<Booking> bookings) {
    return [
      BarChartGroupData(
        x: 0,
        barsSpace: 8.0,
        barRods: [
          BarChartRodData(
            toY: incomeTotal,
            rodStackItems: incomeStack,
            borderRadius: BorderRadius.zero,
            width: 20.0,
          ),
        ],
      ),
      BarChartGroupData(
        x: 1,
        barsSpace: 8.0,
        barRods: [
          BarChartRodData(
            toY: expenseTotal,
            rodStackItems: expenseStack,
            borderRadius: BorderRadius.zero,
            width: 20.0,
          ),
        ],
      ),
    ];
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return BlocProvider(
      key: ValueKey(widget.currentSelectedDate),
      create: (_) => BookingBloc(BookingRepository(), AccountRepository())..add(LoadMonthlyBookings(selectedDate: widget.currentSelectedDate)),
      child: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          if (state is BookingLoading) {
            return CircularLoadingIndicator();
          } else if (state is BookingListLoaded) {
            _prepareBookingList(state.bookings);
            _prepareBarChartData(state.bookings);
            BookingRepository bookingRepository = BookingRepository();
            final Map<int, List<Booking>> bookingsByDay = bookingRepository.groupBookingsByDay(state.bookings);
            return Column(
              children: [
                BookingListOverview(
                  bookings: state.bookings,
                  averageDivider: DateTime(widget.currentSelectedDate.year, widget.currentSelectedDate.month + 1, 0).day,
                  averageText: 'per_day',
                ),
                widget.showBookingChart
                    ? Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: MonthlyBarChart(
                                  bookings: bookingsByDay,
                                  currentSelectedDate: widget.currentSelectedDate,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
                _upcomingBookings.isNotEmpty
                    ? TextButton(
                        onPressed: () {
                          setState(() {
                            widget.onShowUpcomingBookingsChanged?.call(!widget.showUpcomingBookings);

                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _scrollController.animateTo(
                                0,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              );
                            });
                          });
                        },
                        child: Row(
                          children: [
                            Icon(
                              widget.showUpcomingBookings ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_up_rounded,
                              color: Colors.white70,
                            ),
                            SizedBox(width: 4.0),
                            Text(
                              '${t.translate('upcoming_bookings')} (${_upcomingBookings.length})',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      )
                    : SizedBox.shrink(),
                state.bookings.isEmpty
                    ? EmptyList(
                        text: 'no_bookings',
                        icon: FaIcon(
                          FontAwesomeIcons.book,
                          size: 42.0,
                          color: Colors.white70,
                        ),
                      )
                    : Expanded(
                        child: AnimationLimiter(
                          child: ListView.builder(
                            controller: _scrollController,
                            shrinkWrap: true,
                            itemCount: _combinedBookings.length,
                            itemBuilder: (context, index) {
                              final bookingDate = _combinedBookings[index].bookingDate;
                              final bool showHeader = index == 0
                                  ? true
                                  : !isSameDay(
                                      bookingDate,
                                      _combinedBookings[index - 1].bookingDate,
                                    );
                              final bool isDividerPosition = index == _pastStartIndex && index != 0;
                              final blockContent = Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  isDividerPosition
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                                          child: Row(
                                            children: [
                                              const Expanded(child: Divider(indent: 10.0, endIndent: 18.0)),
                                              Text(t.translate('past_bookings')),
                                              const Expanded(child: Divider(indent: 18.0, endIndent: 10.0)),
                                            ],
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                  showHeader
                                      ? BookingListDailyHeader(bookings: _combinedBookings, bookingDate: bookingDate, index: index)
                                      : const SizedBox.shrink(),
                                  BookingCard(
                                    booking: _combinedBookings[index],
                                    onUpdateSuccess: () {
                                      Navigator.pop(context);
                                      Navigator.popAndPushNamed(
                                        context,
                                        homeRoute,
                                        arguments: HomePageArguments(1),
                                      );
                                    },
                                  ),
                                  _combinedBookings.length - 1 == index ? SizedBox(height: 42.0) : SizedBox.shrink(),
                                ],
                              );
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: listAnimationDurationInMs),
                                child: SlideAnimation(
                                  verticalOffset: 40.0,
                                  child: FadeInAnimation(
                                    child: blockContent,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
              ],
            );
          } else if (state is BookingError) {
            return ErrorText(errorMessage: state.message);
          }
          return SizedBox.shrink();
        },
      ),
    );
  }
}
