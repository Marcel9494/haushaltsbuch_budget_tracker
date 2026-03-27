import 'package:flutter/material.dart';
import 'package:haushaltsbuch_budget_tracker/core/utils/currency_formatter.dart';
import 'package:haushaltsbuch_budget_tracker/l10n/app_localizations.dart';

class HomeGridItemCard extends StatefulWidget {
  final Icon icon;
  final String title;
  final double stat;
  final String subtitle;
  bool isSelected;
  final VoidCallback? onTap;

  HomeGridItemCard({
    super.key,
    required this.icon,
    required this.title,
    required this.stat,
    required this.subtitle,
    this.isSelected = false,
    this.onTap,
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
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTap: () {
            setState(() {
              widget.onTap?.call();
              widget.isSelected = !widget.isSelected;
            });
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.isSelected ? Colors.cyanAccent : Colors.transparent,
                width: 1.2,
              ),
            ),
            child: SizedBox(
              width: 178.0,
              child: Card(
                margin: EdgeInsets.zero,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomRight,
                        end: Alignment.topLeft,
                        colors: [
                          Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                          Theme.of(context).colorScheme.primary.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
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
                              Text(
                                t.translate(widget.title),
                                style: TextStyle(color: Colors.white, fontSize: 14.0, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0, bottom: 6.0),
                            child: Text(
                              formatCurrency(widget.stat, 'EUR'),
                              style: TextStyle(fontSize: 21.0, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            t.translate(widget.subtitle),
                            style: TextStyle(color: Colors.white54),
                          ),
                        ],
                      ),
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
