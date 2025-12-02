import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../../../l10n/app_localizations.dart';

class DateNavigation extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateChanged;

  const DateNavigation({
    super.key,
    required this.initialDate,
    required this.onDateChanged,
  });

  @override
  State<DateNavigation> createState() => _DateNavigationState();
}

class _DateNavigationState extends State<DateNavigation> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  void _changeMonth(int offset) {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + offset, 1);
    });
    widget.onDateChanged(_selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_left_rounded),
          onPressed: () => _changeMonth(-1),
        ),
        GestureDetector(
          onTap: () async {
            DateTime? pickedDate = await showMonthPicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              monthPickerDialogSettings: MonthPickerDialogSettings(
                headerSettings: const PickerHeaderSettings(
                  headerCurrentPageTextStyle: TextStyle(fontSize: 20),
                  headerSelectedIntervalTextStyle: TextStyle(fontSize: 20),
                ),
                dateButtonsSettings: const PickerDateButtonsSettings(
                  unselectedMonthsTextColor: Colors.white70,
                  selectedMonthBackgroundColor: Colors.cyanAccent,
                ),
                dialogSettings: PickerDialogSettings(
                  dismissible: true,
                  locale: Localizations.localeOf(context),
                  dialogRoundedCornersRadius: 20,
                  dialogBackgroundColor: Colors.grey[900],
                ),
                actionBarSettings: PickerActionBarSettings(
                  confirmWidget: Text(t.translate('ok'), style: TextStyle(color: Colors.cyanAccent)),
                  cancelWidget: Text(t.translate('cancel'), style: TextStyle(color: Colors.white70)),
                ),
              ),
            );
            if (pickedDate != null) {
              setState(() {
                _selectedDate = DateTime(pickedDate.year, pickedDate.month, 1);
              });
              widget.onDateChanged(_selectedDate);
            }
          },
          child: Container(
            alignment: Alignment.center,
            width: 84.0,
            child: Text(
              formatMonthYear(context, _selectedDate),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_right_rounded),
          onPressed: () => _changeMonth(1),
        ),
      ],
    );
  }
}
