import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../../../blocs/category/category_bloc.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../../../core/utils/slow_hero_animation.dart';
import '../../../../../data/models/booking.dart';
import '../../../../../data/models/budget.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../pages/budget_bookings_page.dart';

class BudgetCard extends StatelessWidget {
  final Budget budget;
  final List<Booking> bookings;
  final double usedBudgetAmount;
  final double percentageUsed;
  final DateTime currentSelectedDate;

  const BudgetCard({
    super.key,
    required this.budget,
    required this.bookings,
    required this.usedBudgetAmount,
    required this.percentageUsed,
    required this.currentSelectedDate,
  });

  double _shouldAmount() {
    final daysInMonth = DateUtils.getDaysInMonth(currentSelectedDate.year, currentSelectedDate.month);
    return (budget.budgetAmount / daysInMonth) * currentSelectedDate.day;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final shouldAmount = _shouldAmount();
    final Color usedColor = usedBudgetAmount < shouldAmount == false ? Colors.red.shade400 : Colors.green.shade400;
    return SlideAnimation(
      verticalOffset: 40.0,
      child: FadeInAnimation(
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            slowHeroRoute(
              BlocProvider.value(
                value: context.read<CategoryBloc>(),
                child: BudgetBookingsPage(
                  budget: budget,
                  bookings: bookings,
                  currentSelectedDate: currentSelectedDate,
                ),
              ),
            ),
          ),
          child: Card(
            child: ClipPath(
              clipper: ShapeBorderClipper(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: usedColor,
                      width: 3.5,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                  child: Row(
                    children: [
                      const SizedBox(width: 2.0),
                      CircularPercentIndicator(
                        radius: 32.0,
                        lineWidth: 6.0,
                        animation: true,
                        percent: (percentageUsed).clamp(0.0, 1.0),
                        center: Text(
                          '${(percentageUsed * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.0,
                          ),
                        ),
                        circularStrokeCap: CircularStrokeCap.round,
                        progressColor: usedColor,
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${budget.category!.categoryName}:',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  formatCurrency(budget.budgetAmount - usedBudgetAmount, 'EUR'),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: usedColor,
                                    fontSize: 16.0,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              '${t.translate('consumed')}: '
                              '${formatCurrency(usedBudgetAmount, 'EUR')} / '
                              '${formatCurrency(budget.budgetAmount, 'EUR')}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              '${t.translate('currently_until')}: '
                              '${formatCurrency(shouldAmount, 'EUR')} '
                              '${t.translate('in_budget')}.',
                              style: const TextStyle(
                                fontSize: 14.0,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
