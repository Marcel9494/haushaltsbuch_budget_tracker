import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../data/enums/period_of_time_type.dart';
import '../../../../../l10n/app_localizations.dart';

class PeriodOfTimeSegmentedButton extends StatefulWidget {
  PeriodOfTimeType periodOfTimeType;
  final ValueChanged<PeriodOfTimeType> onChanged;

  PeriodOfTimeSegmentedButton({
    super.key,
    required this.periodOfTimeType,
    required this.onChanged,
  });

  @override
  State<PeriodOfTimeSegmentedButton> createState() => _PeriodOfTimeSegmentedButtonState();
}

class _PeriodOfTimeSegmentedButtonState extends State<PeriodOfTimeSegmentedButton> {
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return SizedBox(
      child: SegmentedButton<PeriodOfTimeType>(
        segments: <ButtonSegment<PeriodOfTimeType>>[
          ButtonSegment<PeriodOfTimeType>(
            value: PeriodOfTimeType.monthly,
            label: Text(t.translate('month'), style: TextStyle(fontSize: 14.0)),
            icon: FaIcon(FontAwesomeIcons.calendarDays, size: 16.0),
          ),
          ButtonSegment<PeriodOfTimeType>(
            value: PeriodOfTimeType.yearly,
            label: Text(t.translate('year'), style: TextStyle(fontSize: 14.0)),
            icon: FaIcon(FontAwesomeIcons.solidCalendar, size: 16.0),
          ),
        ],
        selected: <PeriodOfTimeType>{widget.periodOfTimeType},
        onSelectionChanged: (Set<PeriodOfTimeType> newPeriodOfTimeTypeSelection) {
          setState(() {
            widget.periodOfTimeType = newPeriodOfTimeTypeSelection.first;
          });
          widget.onChanged(newPeriodOfTimeTypeSelection.first);
        },
        showSelectedIcon: false,
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
          ),
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.cyanAccent.withAlpha(60);
            }
            return null;
          }),
        ),
      ),
    );
  }
}
