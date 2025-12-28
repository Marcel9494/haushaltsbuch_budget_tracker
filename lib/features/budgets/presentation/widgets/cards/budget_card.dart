import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../../../core/utils/currency_formatter.dart';
import '../../../../../data/models/budget.dart';

class BudgetCard extends StatelessWidget {
  final Budget budget;

  const BudgetCard({
    super.key,
    required this.budget,
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
                border: Border(left: BorderSide(color: Colors.cyanAccent, width: 3.5)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ListTile(
                  title: Text(budget.category!.categoryName),
                  trailing: Text(
                    formatCurrency(budget.budgetAmount, 'EUR'),
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
