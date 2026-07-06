import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/consts/animation_consts.dart';
import '../../../../core/utils/date_helper.dart';
import '../../../../data/models/booking.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../bookings/presentation/widgets/cards/booking_card.dart';
import '../../../bookings/presentation/widgets/deco/booking_list_daily_header.dart';
import '../../../shared/presentation/widgets/deco/empty_list.dart';

class CategoryBookingsPage extends StatefulWidget {
  final String category;
  final List<Booking> bookings;
  final DateTime currentSelectedDate;

  const CategoryBookingsPage({
    super.key,
    required this.category,
    required this.bookings,
    required this.currentSelectedDate,
  });

  @override
  State<CategoryBookingsPage> createState() => _CategoryBookingsPageState();
}

class _CategoryBookingsPageState extends State<CategoryBookingsPage> {
  final int _pastStartIndex = 0;
  List<Booking> categoryBookings = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    categoryBookings = widget.bookings.where((booking) => booking.category?.categoryName == widget.category).toList().reversed.toList();
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
      body: Column(
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
                                ? BookingListDailyHeader(bookings: categoryBookings, bookingDate: bookingDate, index: index)
                                : const SizedBox.shrink(),
                            BookingCard(booking: categoryBookings[index]),
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
      ),
    );
  }
}
