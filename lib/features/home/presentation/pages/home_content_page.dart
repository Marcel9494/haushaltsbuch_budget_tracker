import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haushaltsbuch_budget_tracker/features/home/presentation/widgets/cards/guest_info_card.dart';
import 'package:haushaltsbuch_budget_tracker/features/shared/presentation/widgets/deco/subtitle_text.dart';

import '../../../../blocs/booking/booking_bloc.dart';
import '../../../../data/enums/period_of_time_type.dart';
import '../../../../data/models/booking.dart';
import '../../../../data/repositories/booking_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../shared/presentation/widgets/buttons/period_of_time_segmented_button.dart';
import '../../../shared/presentation/widgets/deco/circular_loading_indicator.dart';
import '../../../shared/presentation/widgets/deco/error_text.dart';
import '../widgets/cards/home_grid_item_card.dart';
import '../widgets/charts/category_stats.dart';

class HomeContentPage extends StatefulWidget {
  final DateTime currentSelectedDate;
  final PeriodOfTimeType currentPeriodOfTimeType;
  final ValueChanged<PeriodOfTimeType>? onPeriodOfTimeChanged;

  const HomeContentPage({
    super.key,
    required this.currentSelectedDate,
    required this.currentPeriodOfTimeType,
    required this.onPeriodOfTimeChanged,
  });

  @override
  State<HomeContentPage> createState() => _HomeContentPageState();
}

class _HomeContentPageState extends State<HomeContentPage> {
  late final BookingRepository _bookingRepository = BookingRepository();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        if (state is BookingLoading) {
          return CircularLoadingIndicator();
        } else if (state is BookingListLoaded) {
          double revenue = _bookingRepository.calculateRevenue(state.bookings);
          double expenses = _bookingRepository.calculateExpenses(state.bookings);
          double balance = revenue - expenses;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GuestInfoCard(),
                Padding(
                  padding: const EdgeInsets.only(top: 6.0, bottom: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SubtitleText(text: 'overview'),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: PeriodOfTimeSegmentedButton(
                          periodOfTimeType: widget.currentPeriodOfTimeType,
                          onChanged: (newValue) => widget.onPeriodOfTimeChanged?.call(newValue),
                        ),
                      ),
                    ],
                  ),
                ),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 6,
                  childAspectRatio: 1.6,
                  children: [
                    HomeGridItemCard(
                      icon: FaIcon(FontAwesomeIcons.piggyBank, size: 20.0),
                      title: 'net_assets',
                      stat: 100000,
                      subtitle: 'current_assets',
                    ),
                    HomeGridItemCard(
                      icon: FaIcon(FontAwesomeIcons.coins, size: 20.0),
                      title: 'remaining_amount',
                      stat: balance,
                      subtitle: 'this_month',
                    ),
                    HomeGridItemCard(
                      icon: FaIcon(FontAwesomeIcons.book, size: 20.0),
                      title: 'expenses',
                      stat: expenses,
                      subtitle: 'this_month',
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                SubtitleText(text: 'categories'),
                SizedBox(height: 12.0),
                CategoryStats(
                  bookings: state.bookings,
                  currentSelectedDate: widget.currentSelectedDate,
                  currentPeriodOfTimeType: widget.currentPeriodOfTimeType,
                  onPeriodOfTimeChanged: widget.onPeriodOfTimeChanged,
                ),
              ],
            ),
          );
        } else if (state is YearlyBookingListLoaded) {
          List<Booking> yearlyBookings = state.yearlyBookings.values.expand((bookingList) => bookingList).toList();
          double revenue = _bookingRepository.calculateRevenue(yearlyBookings);
          double expenses = _bookingRepository.calculateExpenses(yearlyBookings);
          double balance = revenue - expenses;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GuestInfoCard(),
                Padding(
                  padding: const EdgeInsets.only(top: 6.0, bottom: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SubtitleText(text: 'overview'),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: PeriodOfTimeSegmentedButton(
                          periodOfTimeType: widget.currentPeriodOfTimeType,
                          onChanged: (newValue) => widget.onPeriodOfTimeChanged?.call(newValue),
                        ),
                      ),
                    ],
                  ),
                ),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 6,
                  childAspectRatio: 1.6,
                  children: [
                    HomeGridItemCard(
                      icon: FaIcon(FontAwesomeIcons.coins, size: 20.0),
                      title: 'remaining_amount',
                      stat: balance,
                      subtitle: 'this_year',
                    ),
                    HomeGridItemCard(
                      icon: FaIcon(FontAwesomeIcons.book, size: 20.0),
                      title: 'expenses',
                      stat: expenses,
                      subtitle: 'this_year',
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                SubtitleText(text: 'categories'),
                SizedBox(height: 12.0),
                CategoryStats(
                  bookings: yearlyBookings,
                  currentSelectedDate: widget.currentSelectedDate,
                  currentPeriodOfTimeType: widget.currentPeriodOfTimeType,
                  onPeriodOfTimeChanged: widget.onPeriodOfTimeChanged,
                ),
              ],
            ),
          );
        } else if (state is BookingError) {
          return ErrorText(errorMessage: state.message);
        }
        return SizedBox.shrink();
      },
    );
  }
}
