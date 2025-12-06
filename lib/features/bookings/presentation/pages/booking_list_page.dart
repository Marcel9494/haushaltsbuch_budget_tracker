import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haushaltsbuch_budget_tracker/data/enums/period_of_time_type.dart';
import 'package:haushaltsbuch_budget_tracker/data/repositories/booking_repository.dart';
import 'package:haushaltsbuch_budget_tracker/features/bookings/presentation/widgets/cards/booking_list_overview_card.dart';
import 'package:haushaltsbuch_budget_tracker/features/bookings/presentation/widgets/list_views/yearly_booking_list.dart';
import 'package:haushaltsbuch_budget_tracker/features/shared/presentation/widgets/buttons/period_of_time_segmented_button.dart';
import 'package:haushaltsbuch_budget_tracker/features/shared/presentation/widgets/deco/empty_list.dart';

import '../../../../blocs/booking/booking_bloc.dart';
import '../../../../data/models/booking.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../shared/presentation/widgets/deco/circular_loading_indicator.dart';
import '../widgets/list_views/monthly_booking_list.dart';

class BookingListPage extends StatefulWidget {
  final DateTime currentSelectedDate;
  final PeriodOfTimeType currentPeriodOfTimeType;
  final ValueChanged<PeriodOfTimeType>? onPeriodOfTimeChanged;

  const BookingListPage({
    super.key,
    required this.currentSelectedDate,
    required this.currentPeriodOfTimeType,
    required this.onPeriodOfTimeChanged,
  });

  @override
  State<BookingListPage> createState() => _BookingListPageState();
}

class _BookingListPageState extends State<BookingListPage> {
  final BookingRepository _bookingRepository = BookingRepository();
  late PeriodOfTimeType _periodOfTimeType = widget.currentPeriodOfTimeType;
  late BookingBloc _bookingBloc;
  bool _showUpcomingBookings = false;
  List<Booking> _pastBookings = [];
  List<Booking> _upcomingBookings = [];
  List<Booking> _combinedBookings = [];
  int _pastStartIndex = 0;

  @override
  void initState() {
    super.initState();
    _bookingBloc = context.read<BookingBloc>();
    _loadMonthlyBookings(widget.currentSelectedDate);
  }

  void _loadMonthlyBookings(DateTime selectedDate) {
    _bookingBloc.add(
      LoadMonthlyBookings(
        selectedDate: selectedDate,
        userId: 'a39f32da-0876-4119-abf4-f636c2a8ad12',
      ),
    );
  }

  void _prepareBookingList(List<Booking> bookings) {
    _pastBookings = bookings.where((b) => b.bookingDate.isBefore(DateTime.now())).toList()..sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
    _upcomingBookings = bookings.where((b) => b.bookingDate.isAfter(DateTime.now())).toList()..sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
    _pastStartIndex = _showUpcomingBookings ? _upcomingBookings.length : 0;
    _combinedBookings = [
      if (_showUpcomingBookings) ..._upcomingBookings,
      ..._pastBookings,
    ];
  }

  @override
  void didUpdateWidget(covariant BookingListPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentSelectedDate != widget.currentSelectedDate) {
      _loadMonthlyBookings(widget.currentSelectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      body: BlocProvider(
        create: (_) => BookingBloc(BookingRepository())
          ..add(LoadMonthlyBookings(selectedDate: widget.currentSelectedDate, userId: 'a39f32da-0876-4119-abf4-f636c2a8ad12')),
        child: BlocBuilder<BookingBloc, BookingState>(
          builder: (context, state) {
            if (state is BookingLoading) {
              return CircularLoadingIndicator();
            } else if (state is BookingListLoaded) {
              // TODO hier weitermachen und jährliche Gesamtbeträge anzeigen implementieren Refactoring nötig?
              final double revenue = _bookingRepository.calculateRevenue(state.bookings);
              final double expenses = _bookingRepository.calculateExpenses(state.bookings);
              final int daysInMonth = DateTime(widget.currentSelectedDate.year, widget.currentSelectedDate.month + 1, 0).day;
              _prepareBookingList(state.bookings);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      BookingListOverviewCard(
                        title: 'revenue',
                        amount: revenue,
                        daysInMonth: daysInMonth,
                        color: Colors.green,
                      ),
                      BookingListOverviewCard(
                        title: 'expenses',
                        amount: expenses,
                        daysInMonth: daysInMonth,
                        color: Colors.redAccent,
                      ),
                      BookingListOverviewCard(
                        title: 'balance',
                        amount: revenue - expenses,
                        daysInMonth: daysInMonth,
                        color: revenue - expenses >= 0 ? Colors.green : Colors.redAccent,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(width: 8.0),
                          InkWell(
                            onTap: () {},
                            customBorder: const CircleBorder(),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.filter_list_alt,
                                size: 24,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                          Container(
                            height: 28,
                            width: 1.2,
                            color: Colors.white70,
                            margin: const EdgeInsets.symmetric(horizontal: 10.0),
                          ),
                          InkWell(
                            onTap: () {},
                            customBorder: const CircleBorder(),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: FaIcon(
                                FontAwesomeIcons.chartColumn,
                                size: 20,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: PeriodOfTimeSegmentedButton(
                          periodOfTimeType: _periodOfTimeType,
                          onChanged: (PeriodOfTimeType newPeriodOfTimeType) {
                            setState(() {
                              _periodOfTimeType = newPeriodOfTimeType;
                            });
                            widget.onPeriodOfTimeChanged?.call(newPeriodOfTimeType);
                          },
                        ),
                      ),
                    ],
                  ),
                  _upcomingBookings.isNotEmpty && _periodOfTimeType == PeriodOfTimeType.monthly
                      ? TextButton(
                          onPressed: () {
                            setState(() {
                              _showUpcomingBookings = !_showUpcomingBookings;
                            });
                          },
                          child: Row(
                            children: [
                              Icon(
                                _showUpcomingBookings ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_up_rounded,
                                color: Colors.white70,
                              ),
                              SizedBox(width: 4.0),
                              Text(
                                t.translate('upcoming_bookings'),
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        )
                      : SizedBox.shrink(),
                  _periodOfTimeType == PeriodOfTimeType.monthly
                      ? _pastBookings.isNotEmpty
                          ? Expanded(
                              child: MonthlyBookingList(
                                bookings: _combinedBookings,
                                pastStartIndex: _pastStartIndex,
                              ),
                            )
                          : EmptyList(
                              text: 'no_bookings',
                              icon: FaIcon(
                                FontAwesomeIcons.book,
                                size: 42.0,
                                color: Colors.white70,
                              ),
                            )
                      : YearlyBookingList(bookings: _combinedBookings, currentSelectedYear: widget.currentSelectedDate.year)
                ],
              );
            } else if (state is BookingError) {
              return Center(child: Text(state.message));
            }
            return SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
