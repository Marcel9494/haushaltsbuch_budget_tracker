import 'package:flutter/material.dart';
import 'package:haushaltsbuch_budget_tracker/core/utils/currency_formatter.dart';

import '../../../../../l10n/app_localizations.dart';

class BookingListOverviewCard extends StatefulWidget {
  final String title;
  final double amount;
  final int averageDivider;
  final String averageText;
  final Color color;

  const BookingListOverviewCard({
    super.key,
    required this.title,
    required this.amount,
    required this.averageDivider,
    required this.averageText,
    required this.color,
  });

  @override
  State<BookingListOverviewCard> createState() => _BookingListOverviewCardState();
}

class _BookingListOverviewCardState extends State<BookingListOverviewCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Expanded(
      child: FadeTransition(
        opacity: _opacity,
        child: SlideTransition(
          position: _slide,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 4.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0, bottom: 2.0),
                    child: Text(
                      t.translate(widget.title),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOut,
                    tween: Tween<double>(begin: 0, end: widget.amount),
                    builder: (context, value, _) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 2.0),
                        child: Text(
                          formatCurrency(value, 'EUR'),
                          style: TextStyle(fontSize: 16.0, color: widget.color),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: Text(
                        '\u00D8 ${formatCurrency(widget.amount / widget.averageDivider, 'EUR')} ${t.translate(widget.averageText)}',
                        key: ValueKey(widget.amount),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
