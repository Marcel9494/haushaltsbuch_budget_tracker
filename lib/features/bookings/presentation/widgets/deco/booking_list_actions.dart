import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../data/enums/period_of_time_type.dart';

class BookingListActions extends StatefulWidget {
  final PeriodOfTimeType periodOfTimeType;
  final bool showBookingChart;
  final ValueChanged<PeriodOfTimeType>? onPeriodOfTimeChanged;
  final ValueChanged<bool>? onShowBookingChartChanged;
  final IconData icon;

  const BookingListActions({
    super.key,
    required this.periodOfTimeType,
    required this.showBookingChart,
    required this.onPeriodOfTimeChanged,
    required this.onShowBookingChartChanged,
    required this.icon,
  });

  @override
  State<BookingListActions> createState() => _BookingListActionsState();
}

class _BookingListActionsState extends State<BookingListActions> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fade = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
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
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: InkWell(
          onTap: () {
            setState(() {
              widget.onShowBookingChartChanged?.call(!widget.showBookingChart);
            });
          },
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: FaIcon(
              widget.icon,
              size: 20,
              color: widget.showBookingChart ? Colors.cyanAccent : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}
