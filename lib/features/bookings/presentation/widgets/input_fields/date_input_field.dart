import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haushaltsbuch_budget_tracker/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../data/enums/repetition_type.dart';

class DateInputField extends StatefulWidget {
  final TextEditingController dateController;
  final RepetitionType repetitionType;
  final ValueChanged<RepetitionType> onRepetitionTypeChanged;

  const DateInputField({
    super.key,
    required this.dateController,
    required this.repetitionType,
    required this.onRepetitionTypeChanged,
  });

  @override
  State<DateInputField> createState() => _DateInputFieldState();
}

class _DateInputFieldState extends State<DateInputField> {
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(t.translate('booking_date'), style: TextStyle(fontSize: 16.0)),
        ),
        TextFormField(
          controller: widget.dateController,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.calendar_month_rounded, size: 22.0),
            suffixIcon: SizedBox(
              width: 165.0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: 24,
                    width: 1.3,
                    color: Colors.white30,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                          ),
                          builder: (context) {
                            final double bottomSheetHeight = MediaQuery.of(context).size.height * 0.6;
                            return SafeArea(
                              child: SizedBox(
                                height: bottomSheetHeight,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${t.translate('repetition')}:',
                                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.close, size: 28),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Expanded(
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: RepetitionType.values.length,
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                                              child: OutlinedButton(
                                                onPressed: () {
                                                  widget.onRepetitionTypeChanged(RepetitionType.values[index]);
                                                  Navigator.pop(context);
                                                },
                                                style: OutlinedButton.styleFrom(
                                                  side: BorderSide(
                                                      color: widget.repetitionType == RepetitionType.values[index] ? Colors.cyanAccent : Colors.grey,
                                                      width: widget.repetitionType == RepetitionType.values[index] ? 1 : 0.5),
                                                  backgroundColor: Colors.black87,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                ),
                                                child: Text(t.translate(RepetitionType.values[index].name),
                                                    style: TextStyle(
                                                        color: widget.repetitionType == RepetitionType.values[index]
                                                            ? Colors.cyanAccent
                                                            : Colors.white70)),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Text(t.translate(widget.repetitionType.name), overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  IconButton(
                    icon: FaIcon(FontAwesomeIcons.repeat, size: 18.0),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                        ),
                        builder: (context) {
                          final double bottomSheetHeight = MediaQuery.of(context).size.height * 0.6;
                          return SafeArea(
                            child: SizedBox(
                              height: bottomSheetHeight,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${t.translate('repetition')}:',
                                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close, size: 28),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Expanded(
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: RepetitionType.values.length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                                            child: OutlinedButton(
                                              onPressed: () {
                                                widget.onRepetitionTypeChanged(RepetitionType.values[index]);
                                                Navigator.pop(context);
                                              },
                                              style: OutlinedButton.styleFrom(
                                                side: BorderSide(
                                                    color: widget.repetitionType == RepetitionType.values[index] ? Colors.cyanAccent : Colors.grey,
                                                    width: widget.repetitionType == RepetitionType.values[index] ? 1 : 0.5),
                                                backgroundColor: Colors.black87,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: Text(t.translate(RepetitionType.values[index].name),
                                                  style: TextStyle(
                                                      color: widget.repetitionType == RepetitionType.values[index]
                                                          ? Colors.cyanAccent
                                                          : Colors.white70)),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            isDense: true,
            filled: true,
            fillColor: Colors.black87,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey, width: 0.3),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey, width: 0.3),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey, width: 0.3),
            ),
          ),
          readOnly: true,
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              locale: Localizations.localeOf(context),
              initialDate: DateFormat('(E) dd.MM.yyyy', Localizations.localeOf(context).languageCode).parse(widget.dateController.text),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              confirmText: t.translate('ok'),
              cancelText: t.translate('cancel'),
            );

            if (pickedDate != null) {
              String formattedDate = DateFormat('(E) dd.MM.yyyy', Localizations.localeOf(context).languageCode).format(pickedDate);
              setState(() {
                widget.dateController.text = formattedDate;
              });
            }
          },
        ),
      ],
    );
  }
}
