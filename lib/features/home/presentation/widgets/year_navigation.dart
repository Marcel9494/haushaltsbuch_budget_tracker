import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

import '../../../../l10n/app_localizations.dart';

class YearNavigation extends StatefulWidget {
  final int initialYear;
  final ValueChanged<int> onYearChanged;

  const YearNavigation({
    super.key,
    required this.initialYear,
    required this.onYearChanged,
  });

  @override
  State<YearNavigation> createState() => _YearNavigationState();
}

class _YearNavigationState extends State<YearNavigation> {
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialYear;
  }

  void _changeYear(int offset) {
    setState(() {
      _selectedYear = _selectedYear + offset;
    });
    widget.onYearChanged(_selectedYear);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_left_rounded),
          onPressed: () => _changeYear(-1),
        ),
        GestureDetector(
          onTap: () async {
            int? pickedDate = await showYearPicker(
              context: context,
              initialDate: DateTime(_selectedYear, 1, 1),
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
                _selectedYear = pickedDate;
              });
              widget.onYearChanged(_selectedYear);
            }
          },
          child: Container(
            alignment: Alignment.center,
            width: 84.0,
            child: Text(
              _selectedYear.toString(),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_right_rounded),
          onPressed: () => _changeYear(1),
        ),
      ],
    );
  }
}
