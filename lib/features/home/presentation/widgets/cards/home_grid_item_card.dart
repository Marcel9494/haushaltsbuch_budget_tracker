import 'package:flutter/material.dart';
import 'package:haushaltsbuch_budget_tracker/core/utils/currency_formatter.dart';
import 'package:haushaltsbuch_budget_tracker/l10n/app_localizations.dart';

class HomeGridItemCard extends StatefulWidget {
  final Icon icon;
  final String title;
  final double stat;
  final String subtitle;

  const HomeGridItemCard({
    super.key,
    required this.icon,
    required this.title,
    required this.stat,
    required this.subtitle,
  });

  @override
  State<HomeGridItemCard> createState() => _HomeGridItemCardState();
}

class _HomeGridItemCardState extends State<HomeGridItemCard> with TickerProviderStateMixin {
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
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: widget.icon,
                    ),
                    Text(t.translate(widget.title)),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Text(
                    formatCurrency(widget.stat, 'EUR'),
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(t.translate(widget.subtitle)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
