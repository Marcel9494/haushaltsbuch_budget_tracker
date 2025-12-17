import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haushaltsbuch_budget_tracker/features/shared/presentation/widgets/deco/subtitle_text.dart';
import 'package:haushaltsbuch_budget_tracker/l10n/app_localizations.dart';

import '../../../../blocs/booking/booking_bloc.dart';
import '../../../../data/enums/period_of_time_type.dart';
import '../../../../data/models/booking.dart';
import '../../../../data/repositories/booking_repository.dart';
import '../../../shared/presentation/widgets/buttons/period_of_time_segmented_button.dart';
import '../../../shared/presentation/widgets/deco/circular_loading_indicator.dart';
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
    // TODO einbauen, wenn AccountBloc steht mit MultiBloc... Widgets
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
                SubtitleText(text: 'overview'),
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
                      title: 'Vermögen',
                      stat: 100000,
                      subtitle: 'Aktuelles Vermögen',
                    ),
                    HomeGridItemCard(
                      icon: FaIcon(FontAwesomeIcons.coins, size: 20.0),
                      title: 'Restlicher Betrag',
                      stat: balance,
                      subtitle: 'diesen Monat',
                    ),
                    HomeGridItemCard(
                      icon: FaIcon(FontAwesomeIcons.book, size: 20.0),
                      title: 'Ausgaben',
                      stat: expenses,
                      subtitle: 'diesen Monat',
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SubtitleText(text: 'categories'),
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
                SubtitleText(text: 'overview'),
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
                      title: 'Restlicher Betrag',
                      stat: balance,
                      subtitle: 'dieses Jahr',
                    ),
                    HomeGridItemCard(
                      icon: FaIcon(FontAwesomeIcons.book, size: 20.0),
                      title: 'Ausgaben',
                      stat: expenses,
                      subtitle: 'dieses Jahr',
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SubtitleText(text: 'categories'),
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
                CategoryStats(
                  bookings: yearlyBookings,
                  currentSelectedDate: widget.currentSelectedDate,
                  currentPeriodOfTimeType: widget.currentPeriodOfTimeType,
                  onPeriodOfTimeChanged: widget.onPeriodOfTimeChanged,
                ),
              ],
            ),
          );
        }
        return SizedBox.shrink();
      },
    );
  }
}
