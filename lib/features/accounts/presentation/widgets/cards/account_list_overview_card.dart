import 'package:flutter/material.dart';

import '../../../../../core/utils/currency_formatter.dart';
import '../../../../../l10n/app_localizations.dart';

class AccountListOverviewCard extends StatefulWidget {
  final String title;
  final double amount;
  final Icon icon;
  final Color color;

  const AccountListOverviewCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  State<AccountListOverviewCard> createState() => _AccountListOverviewCardState();
}

class _AccountListOverviewCardState extends State<AccountListOverviewCard> with SingleTickerProviderStateMixin {
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
              padding: const EdgeInsets.only(top: 12.0, left: 12.0, right: 4.0, bottom: 2.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.icon,
                  SizedBox(height: 8.0),
                  Text(
                    t.translate(widget.title),
                    style: const TextStyle(
                      color: Colors.white,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOut,
                    tween: Tween<double>(begin: 0, end: widget.amount),
                    builder: (context, value, _) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                        child: Text(
                          formatCurrency(value, 'EUR'),
                          style: TextStyle(
                            fontSize: 16.0,
                            color: widget.color,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    },
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
