import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:haushaltsbuch_budget_tracker/core/consts/route_consts.dart';
import 'package:haushaltsbuch_budget_tracker/core/page_arguments/category_bookings_page_arguments.dart';
import 'package:haushaltsbuch_budget_tracker/data/helper_models/booking_category_stats.dart';
import 'package:intl/intl.dart';

import '../../../../../core/utils/currency_formatter.dart';
import '../../../../../data/models/booking.dart';
import '../../../../../l10n/app_localizations.dart';

class CategoryStatCard extends StatelessWidget {
  final BookingCategoryStats bookingCategoryStats;
  final Color pieCategoryColor;
  final List<Booking> bookings;
  final DateTime currentSelectedDate;

  const CategoryStatCard({
    super.key,
    required this.bookingCategoryStats,
    required this.pieCategoryColor,
    required this.bookings,
    required this.currentSelectedDate,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    return SlideAnimation(
      verticalOffset: 40.0,
      child: FadeInAnimation(
        child: GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              categoryBookingsRoute,
              arguments: CategoryBookingsPageArguments(
                bookingCategoryStats.category,
                bookings,
                currentSelectedDate,
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
