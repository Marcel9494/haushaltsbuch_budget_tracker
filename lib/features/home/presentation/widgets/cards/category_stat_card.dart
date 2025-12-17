import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:haushaltsbuch_budget_tracker/data/helper_models/booking_category_stats.dart';

import '../../../../../core/utils/currency_formatter.dart';

class CategoryStatCard extends StatelessWidget {
  final BookingCategoryStats bookingCategoryStats;
  final Color pieCategoryColor;

  const CategoryStatCard({
    super.key,
    required this.bookingCategoryStats,
    required this.pieCategoryColor,
  });

  @override
  Widget build(BuildContext context) {
    return SlideAnimation(
      verticalOffset: 40.0,
      child: FadeInAnimation(
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
                  title: Text(
                    '${bookingCategoryStats.percentage.toStringAsFixed(1)}% ${bookingCategoryStats.category}',
                  ),
                  trailing: Text(
                    formatCurrency(bookingCategoryStats.totalAmount, 'EUR'),
                    style: TextStyle(fontSize: 16.0),
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
