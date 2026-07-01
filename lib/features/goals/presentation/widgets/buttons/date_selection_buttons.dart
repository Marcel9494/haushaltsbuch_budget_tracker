import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../../../../core/utils/date_helper.dart';
import '../../../../../l10n/app_localizations.dart';

class DateSelectionButtons extends StatefulWidget {
  final TextEditingController startDateController;
  final ValueChanged<DateTime> onStartDateChanged;
  final TextEditingController endDateController;
  final ValueChanged<DateTime> onEndDateChanged;

  const DateSelectionButtons({
    super.key,
    required this.startDateController,
    required this.onStartDateChanged,
    required this.endDateController,
    required this.onEndDateChanged,
  });

  @override
  State<DateSelectionButtons> createState() => _DateSelectionButtonsState();
}

class _DateSelectionButtonsState extends State<DateSelectionButtons> {
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    locale: Localizations.localeOf(context),
                    initialDate: DateFormat('(E) dd.MM.yyyy', Localizations.localeOf(context).languageCode).parse(widget.startDateController.text),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    confirmText: t.translate('ok'),
                    cancelText: t.translate('cancel'),
                  );

                  if (pickedDate != null) {
                    String formattedDate = DateFormat('(E) dd.MM.yyyy', Localizations.localeOf(context).languageCode).format(pickedDate);
                    setState(() {
                      widget.startDateController.text = formattedDate;
                    });
                  }
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const FaIcon(FontAwesomeIcons.calendar, size: 24.0),
                        const SizedBox(height: 8),
                        Text(
                          '${t.translate('start_date')}\n${widget.startDateController.text}',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const FaIcon(FontAwesomeIcons.arrowRight, size: 24.0),
              GestureDetector(
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    locale: Localizations.localeOf(context),
                    initialDate: DateFormat('(E) dd.MM.yyyy', Localizations.localeOf(context).languageCode).parse(widget.endDateController.text),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    confirmText: t.translate('ok'),
                    cancelText: t.translate('cancel'),
                  );

                  if (pickedDate != null) {
                    String formattedDate = DateFormat('(E) dd.MM.yyyy', Localizations.localeOf(context).languageCode).format(pickedDate);
                    setState(() {
                      widget.endDateController.text = formattedDate;
                    });
                  }
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const FaIcon(FontAwesomeIcons.solidCalendarCheck, size: 24.0),
                        const SizedBox(height: 8),
                        Text(
                          '${t.translate('end_date')}\n${widget.endDateController.text}',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Builder(
            builder: (context) {
              try {
                final locale = Localizations.localeOf(context).languageCode;
                DateTime startDate = DateFormat('(E) dd.MM.yyyy', locale).parse(widget.startDateController.text);
                DateTime endDate = DateFormat('(E) dd.MM.yyyy', locale).parse(widget.endDateController.text);
                String duration = formatDateDuration(startDate, endDate);

                return Column(
                  children: [
                    const SizedBox(height: 16.0),
                    Text(
                      duration,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15.0),
                    ),
                  ],
                );
              } catch (e) {
                return const Text('');
              }
            },
          ),
        ],
      ),
    );
  }
}
