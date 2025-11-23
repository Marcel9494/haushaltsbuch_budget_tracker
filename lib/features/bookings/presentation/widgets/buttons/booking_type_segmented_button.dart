import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../data/enums/booking_type.dart';

class BookingTypeSegmentedButton extends StatefulWidget {
  BookingType bookingType;
  final ValueChanged<BookingType> onChanged;

  BookingTypeSegmentedButton({
    super.key,
    required this.bookingType,
    required this.onChanged,
  });

  @override
  State<BookingTypeSegmentedButton> createState() => _BookingTypeSegmentedButtonState();
}

class _BookingTypeSegmentedButtonState extends State<BookingTypeSegmentedButton> {
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<BookingType>(
        segments: <ButtonSegment<BookingType>>[
          ButtonSegment<BookingType>(
            value: BookingType.expense,
            label: Text(t.translate('expense')),
            icon: Icon(Icons.remove_rounded),
          ),
          ButtonSegment<BookingType>(
            value: BookingType.income,
            label: Text(t.translate('income')),
            icon: Icon(Icons.add_rounded),
          ),
          ButtonSegment<BookingType>(
            value: BookingType.transfer,
            label: Text(t.translate('transfer')),
            icon: Icon(Icons.compare_arrows_rounded),
          ),
        ],
        selected: <BookingType>{widget.bookingType},
        onSelectionChanged: (Set<BookingType> newBookingTypeSelection) {
          setState(() {
            widget.bookingType = newBookingTypeSelection.first;
          });
          widget.onChanged(newBookingTypeSelection.first);
        },
        showSelectedIcon: false,
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(4),
              ),
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
