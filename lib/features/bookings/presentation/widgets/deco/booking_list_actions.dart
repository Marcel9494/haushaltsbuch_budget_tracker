import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../data/enums/period_of_time_type.dart';
import '../../../../shared/presentation/widgets/buttons/period_of_time_segmented_button.dart';

class BookingListActions extends StatefulWidget {
  final PeriodOfTimeType periodOfTimeType;
  final ValueChanged<PeriodOfTimeType>? onPeriodOfTimeChanged;

  const BookingListActions({
    super.key,
    required this.periodOfTimeType,
    required this.onPeriodOfTimeChanged,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const SizedBox(width: 8.0),
                InkWell(
                  onTap: () {},
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.filter_list_alt,
                      size: 24,
                      color: Colors.white70,
                    ),
                  ),
                ),
                Container(
                  height: 28,
                  width: 1.2,
                  color: Colors.white70,
                  margin: const EdgeInsets.symmetric(horizontal: 10.0),
                ),
                InkWell(
                  onTap: () {},
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FaIcon(
                      FontAwesomeIcons.chartColumn,
                      size: 20,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: PeriodOfTimeSegmentedButton(
                periodOfTimeType: widget.periodOfTimeType,
                onChanged: (newValue) => widget.onPeriodOfTimeChanged?.call(newValue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
