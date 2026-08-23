import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haushaltsbuch_budget_tracker/data/enums/period_of_time_type.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

import '../../../../../core/utils/date_formatter.dart';
import '../../../../../l10n/app_localizations.dart';

class DatePickerBar extends StatefulWidget {
  final DateTime initialDate;
  PeriodOfTimeType currentPeriodOfTime;
  final void Function(DateTime date, PeriodOfTimeType currentPeriodOfTime) onDateChanged;
  final void Function(DateTime date, PeriodOfTimeType currentPeriodOfTime) onPageChanged;
  final void Function(PeriodOfTimeType currentPeriodOfTime)? onPeriodOfTimeChanged;

  DatePickerBar({
    super.key,
    required this.initialDate,
    this.currentPeriodOfTime = PeriodOfTimeType.monthly,
    required this.onDateChanged,
    required this.onPageChanged,
    required this.onPeriodOfTimeChanged,
  });

  @override
  State<DatePickerBar> createState() => _DatePickerBarState();
}

class _DatePickerBarState extends State<DatePickerBar> {
  late PageController _controller;
  late DateTime _selectedDate;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();

    _currentIndex = 1000;
    _selectedDate = widget.initialDate;

    _controller = PageController(
      initialPage: _currentIndex,
      viewportFraction: 0.25, // wie viele Monate sollen sichtbar sein
    );
  }

  @override
  void didUpdateWidget(covariant DatePickerBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialDate != oldWidget.initialDate) {
      final newIndex = _getIndexFromMonth(widget.initialDate);

      setState(() {
        _selectedDate = widget.initialDate;
        _currentIndex = newIndex;
      });

      _controller.jumpToPage(newIndex);
    }
  }

  DateTime _getDateFromIndex(int index, PeriodOfTimeType currentPeriodOfTime) {
    int offset = index - 1000;
    if (currentPeriodOfTime == PeriodOfTimeType.yearly) {
      return DateTime(widget.initialDate.year + offset, widget.initialDate.month, 1);
    } else {
      return DateTime(widget.initialDate.year, widget.initialDate.month + offset, 1);
    }
  }

  int _getIndexFromMonth(DateTime date) {
    final initial = widget.initialDate;

    int yearDiff = date.year - initial.year;
    int monthDiff = date.month - initial.month;

    int totalMonthDiff = yearDiff * 12 + monthDiff;

    return 1000 + totalMonthDiff;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      height: 65,
      color: Theme.of(context).cardColor,
      child: Row(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (index) {
                final newDate = _getDateFromIndex(index, widget.currentPeriodOfTime);
                _currentIndex = index;
                _selectedDate = newDate;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  widget.onPageChanged(newDate, widget.currentPeriodOfTime);
                });
              },
              itemBuilder: (context, index) {
                final currentDate = _getDateFromIndex(index, widget.currentPeriodOfTime);
                final isSelected = index == _currentIndex;
                return GestureDetector(
                  onTap: () async {
                    if (isSelected) {
                      final DateTime? pickedDate;
                      if (widget.currentPeriodOfTime == PeriodOfTimeType.yearly) {
                        final pickedYear = await showYearPicker(
                          context: context,
                          initialDate: currentDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          monthPickerDialogSettings: MonthPickerDialogSettings(
                            headerSettings: PickerHeaderSettings(
                              headerCurrentPageTextStyle: TextStyle(fontSize: 20),
                              headerSelectedIntervalTextStyle: TextStyle(fontSize: 20),
                              headerBackgroundColor: Colors.grey[900],
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

                        if (pickedYear != null) {
                          final newDate = DateTime(pickedYear, currentDate.month, 1);
                          final newIndex = _getIndexFromMonth(newDate);

                          setState(() {
                            _selectedDate = newDate;
                            _currentIndex = newIndex;
                          });

                          _controller.animateToPage(
                            newIndex,
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );

                          widget.onDateChanged(_selectedDate, widget.currentPeriodOfTime);
                        }
                        return;
                      } else {
                        pickedDate = await showMonthPicker(
                          context: context,
                          initialDate: currentDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          monthPickerDialogSettings: MonthPickerDialogSettings(
                            headerSettings: PickerHeaderSettings(
                              headerCurrentPageTextStyle: TextStyle(fontSize: 20),
                              headerSelectedIntervalTextStyle: TextStyle(fontSize: 20),
                              headerBackgroundColor: Colors.grey[900],
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
                      }
                      if (pickedDate != null) {
                        final newDate = DateTime(pickedDate.year, pickedDate.month, 1);
                        final newIndex = _getIndexFromMonth(newDate);

                        setState(() {
                          _selectedDate = newDate;
                          _currentIndex = newIndex;
                        });

                        _controller.animateToPage(
                          newIndex,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );

                        widget.onDateChanged(_selectedDate, widget.currentPeriodOfTime);
                      }
                    } else {
                      setState(() {
                        _currentIndex = index;
                        _selectedDate = _getDateFromIndex(_currentIndex, widget.currentPeriodOfTime);
                      });

                      _controller.animateToPage(
                        index,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                      widget.onDateChanged(_selectedDate, widget.currentPeriodOfTime);
                    }
                  },
                  child: Center(
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                      decoration: isSelected
                          ? BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(8.0),
                            )
                          : null,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          isSelected
                              ? widget.currentPeriodOfTime == PeriodOfTimeType.yearly
                                  ? Card(
                                      margin: EdgeInsets.only(bottom: 2.0),
                                      elevation: 8.0,
                                      child: SizedBox(
                                        height: 55.0,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(12.0, 16.0, 12.0, 0.0),
                                          child: Text(
                                            formatYear(context, currentDate),
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              color: Colors.cyanAccent,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Card(
                                      margin: EdgeInsets.only(bottom: 2.0),
                                      elevation: 8.0,
                                      child: SizedBox(
                                        height: 55.0,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                          child: Column(
                                            children: [
                                              Text(
                                                formatYear(context, currentDate),
                                                style: TextStyle(fontSize: 12.0, color: Colors.grey),
                                              ),
                                              SizedBox(height: 2.0),
                                              Text(
                                                formatShortMonth(context, currentDate),
                                                style: TextStyle(
                                                  fontSize: 16.0,
                                                  color: Colors.cyanAccent,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                              : Text(
                                  widget.currentPeriodOfTime == PeriodOfTimeType.yearly
                                      ? formatYear(context, currentDate)
                                      : formatShortMonth(context, currentDate),
                                  style: TextStyle(
                                    fontSize: isSelected ? 16.0 : 14.0,
                                    color: isSelected ? Colors.cyanAccent : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.cyanAccent.withAlpha(20),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextButton(
                onPressed: () {
                  setState(() {
                    widget.currentPeriodOfTime == PeriodOfTimeType.yearly
                        ? widget.currentPeriodOfTime = PeriodOfTimeType.monthly
                        : widget.currentPeriodOfTime = PeriodOfTimeType.yearly;
                    widget.onPeriodOfTimeChanged?.call(widget.currentPeriodOfTime);
                  });
                },
                style: TextButton.styleFrom(overlayColor: Colors.transparent),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FaIcon(widget.currentPeriodOfTime == PeriodOfTimeType.yearly ? FontAwesomeIcons.calendar : Icons.calendar_month_outlined,
                        size: widget.currentPeriodOfTime == PeriodOfTimeType.yearly ? 16.0 : 18.0, color: Colors.cyanAccent),
                    SizedBox(height: 2.0),
                    Text(
                      widget.currentPeriodOfTime == PeriodOfTimeType.yearly ? t.translate('year') : t.translate('month'),
                      style: TextStyle(fontSize: 12.0, color: Colors.cyanAccent),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
