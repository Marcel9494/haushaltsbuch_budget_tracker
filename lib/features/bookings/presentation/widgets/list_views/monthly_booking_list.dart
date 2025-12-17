import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haushaltsbuch_budget_tracker/data/enums/period_of_time_type.dart';
import 'package:haushaltsbuch_budget_tracker/features/bookings/presentation/widgets/deco/booking_list_actions.dart';
import 'package:haushaltsbuch_budget_tracker/features/bookings/presentation/widgets/deco/booking_list_daily_header.dart';
import 'package:haushaltsbuch_budget_tracker/features/bookings/presentation/widgets/deco/booking_list_overview.dart';

import '../../../../../blocs/booking/booking_bloc.dart';
import '../../../../../core/consts/animation_consts.dart';
import '../../../../../data/models/booking.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../shared/presentation/widgets/deco/circular_loading_indicator.dart';
import '../../../../shared/presentation/widgets/deco/empty_list.dart';
import '../cards/booking_card.dart';

class MonthlyBookingList extends StatefulWidget {
  final DateTime currentSelectedDate;
  PeriodOfTimeType periodOfTimeType;
  final ValueChanged<PeriodOfTimeType>? onPeriodOfTimeChanged;

  MonthlyBookingList({
    super.key,
    required this.currentSelectedDate,
    required this.periodOfTimeType,
    required this.onPeriodOfTimeChanged,
  });

  @override
  State<MonthlyBookingList> createState() => _MonthlyBookingListState();
}

class _MonthlyBookingListState extends State<MonthlyBookingList> {
  bool _showUpcomingBookings = false;
  List<Booking> _pastBookings = [];
  List<Booking> _upcomingBookings = [];
  List<Booking> _combinedBookings = [];
  int _pastStartIndex = 0;

  void _prepareBookingList(List<Booking> bookings) {
    _pastBookings = bookings.where((b) => b.bookingDate.isBefore(DateTime.now())).toList()..sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
    _upcomingBookings = bookings.where((b) => b.bookingDate.isAfter(DateTime.now())).toList()..sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
    _pastStartIndex = _showUpcomingBookings ? _upcomingBookings.length : 0;
    _combinedBookings = [
      if (_showUpcomingBookings) ..._upcomingBookings,
      ..._pastBookings,
    ];
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        if (state is BookingLoading) {
          return CircularLoadingIndicator();
        } else if (state is BookingListLoaded) {
          _prepareBookingList(state.bookings);
          return Column(
            children: [
              BookingListOverview(
                bookings: state.bookings,
                averageDivider: DateTime(widget.currentSelectedDate.year, widget.currentSelectedDate.month + 1, 0).day,
                averageText: 'per_day',
              ),
              BookingListActions(
                periodOfTimeType: widget.periodOfTimeType,
                onPeriodOfTimeChanged: widget.onPeriodOfTimeChanged,
              ),
              _upcomingBookings.isNotEmpty
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
                          shrinkWrap: true,
                          itemCount: _combinedBookings.length,
                          itemBuilder: (context, index) {
                            final bookingDate = _combinedBookings[index].bookingDate;
                            final bool showHeader = index == 0
                                ? true
                                : !_isSameDay(
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
                                BookingCard(booking: _combinedBookings[index]),
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
          return Center(child: Text(state.message));
        }
        return SizedBox.shrink();
      },
    );
  }
}
