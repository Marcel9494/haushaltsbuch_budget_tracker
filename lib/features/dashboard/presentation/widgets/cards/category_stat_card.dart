import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:haushaltsbuch_budget_tracker/data/enums/period_of_time_type.dart';
import 'package:haushaltsbuch_budget_tracker/data/helper_models/booking_category_stats.dart';
import 'package:intl/intl.dart';

import '../../../../../blocs/account/account_bloc.dart';
import '../../../../../blocs/booking/booking_bloc.dart';
import '../../../../../blocs/category/category_bloc.dart';
import '../../../../../blocs/goal/goal_bloc.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../../../data/models/booking.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../categories/presentation/pages/category_bookings_page.dart';

class CategoryStatCard extends StatelessWidget {
  final BookingCategoryStats bookingCategoryStats;
  final Color pieCategoryColor;
  final List<Booking> bookings;
  final DateTime currentSelectedDate;
  final PeriodOfTimeType currentPeriodOfTimeType;

  const CategoryStatCard({
    super.key,
    required this.bookingCategoryStats,
    required this.pieCategoryColor,
    required this.bookings,
    required this.currentSelectedDate,
    required this.currentPeriodOfTimeType,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    return SlideAnimation(
      verticalOffset: 40.0,
      child: FadeInAnimation(
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: context.read<BookingBloc>()),
                    BlocProvider.value(value: context.read<CategoryBloc>()),
                    BlocProvider.value(value: context.read<AccountBloc>()),
                    BlocProvider.value(value: context.read<GoalBloc>()),
                  ],
                  child: CategoryBookingsPage(
                    category: bookingCategoryStats.category,
                    bookings: bookings,
                    currentSelectedDate: currentSelectedDate,
                    currentPeriodOfTimeType: currentPeriodOfTimeType,
                  ),
                ),
              ),
            );
          },
          child: Card(
            child: ClipPath(
              clipper: ShapeBorderClipper(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(left: BorderSide(color: pieCategoryColor, width: 3.5)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ListTile(
                    dense: true,
                    title: Text(
                      '${NumberFormat('#,##0.0', locale).format(bookingCategoryStats.percentage)}% ${bookingCategoryStats.category == 'no_category' ? AppLocalizations.of(context).translate('no_category') : bookingCategoryStats.category}',
                      style: TextStyle(fontSize: 15.0),
                    ),
                    trailing: Text(
                      formatCurrency(bookingCategoryStats.totalAmount, 'EUR'),
                      style: TextStyle(fontSize: 15.0),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
