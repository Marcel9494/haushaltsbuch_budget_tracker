import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haushaltsbuch_budget_tracker/data/enums/period_of_time_type.dart';

import '../../../../blocs/booking/booking_bloc.dart';
import '../../../../core/consts/animation_consts.dart';
import '../../../../core/utils/date_helper.dart';
import '../../../../data/enums/booking_type.dart';
import '../../../../data/models/booking.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../bookings/presentation/widgets/cards/booking_card.dart';
import '../../../bookings/presentation/widgets/deco/booking_list_daily_header.dart';
import '../../../shared/presentation/widgets/deco/circular_loading_indicator.dart';
import '../../../shared/presentation/widgets/deco/empty_list.dart';
import '../../../shared/presentation/widgets/deco/error_text.dart';

class CategoryBookingsPage extends StatefulWidget {
  final String category;
  final BookingType bookingType;
  final List<Booking> bookings;
  final DateTime currentSelectedDate;
  final PeriodOfTimeType currentPeriodOfTimeType;

  const CategoryBookingsPage({
    super.key,
    required this.category,
    required this.bookingType,
    required this.bookings,
    required this.currentSelectedDate,
    required this.currentPeriodOfTimeType,
  });

  @override
  State<CategoryBookingsPage> createState() => _CategoryBookingsPageState();
}

class _CategoryBookingsPageState extends State<CategoryBookingsPage> {
  final ScrollController _scrollController = ScrollController();

  List<Booking> _filterCategoryBookings(List<Booking> bookings) {
    List<Booking> categoryBookings = bookings.where((booking) {
      return booking.category?.categoryName == widget.category && booking.bookingType == widget.bookingType;
    }).toList();
    return categoryBookings;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category == 'no_category'
              ? '${t.translate('no_category')} ${t.translate('bookings')}'
              : '${widget.category} ${t.translate('bookings')}',
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          if (state is BookingLoading) {
            return CircularLoadingIndicator();
          } else if (state is BookingListLoaded || state is YearlyBookingListLoaded) {
            List<Booking> categoryBookings = [];
            if (state is BookingListLoaded) {
              categoryBookings = _filterCategoryBookings(state.bookings);
            } else if (state is YearlyBookingListLoaded) {
              categoryBookings = _filterCategoryBookings(state.yearlyBookings.values.expand((bookingList) => bookingList).toList());
            }
            return Column(
              children: [
                categoryBookings.isEmpty
                    ? EmptyList(
                        text: 'no_bookings_for_category',
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
                            itemCount: categoryBookings.length,
                            itemBuilder: (context, index) {
                              final bookingDate = categoryBookings[index].bookingDate;
                              final bool showHeader = index == 0
                                  ? true
                                  : !isSameDay(
                                      bookingDate,
                                      categoryBookings[index - 1].bookingDate,
                                    );
                              final bool isDividerPosition = index == 0 && index != 0;
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
                                      ? BookingListDailyHeader(bookings: categoryBookings, bookingDate: bookingDate, index: index)
                                      : const SizedBox.shrink(),
                                  BookingCard(
                                    booking: categoryBookings[index],
                                    onUpdateSuccess: () {
                                      Navigator.pop(context);
                                      if (widget.currentPeriodOfTimeType == PeriodOfTimeType.monthly) {
                                        context.read<BookingBloc>().add(LoadMonthlyBookings(selectedDate: widget.currentSelectedDate));
                                      } else if (widget.currentPeriodOfTimeType == PeriodOfTimeType.yearly) {
                                        context.read<BookingBloc>().add(LoadYearlyBookings(selectedYear: widget.currentSelectedDate.year));
                                      }
                                    },
                                  ),
                                  categoryBookings.length - 1 == index ? SizedBox(height: 42.0) : SizedBox.shrink(),
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
