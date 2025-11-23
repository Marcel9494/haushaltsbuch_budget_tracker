import 'package:flutter/material.dart';

import '../../../data/enums/amount_type.dart';
import '../../../data/enums/booking_type.dart';
import 'amount_type_bottom_sheet.dart';

class ShowAmountTypeBottomSheet {
  static Future<void> show(
    BuildContext context, {
    required AmountType selected,
    required BookingType bookingType,
    required ValueChanged<AmountType> onChanged,
  }) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => AmountTypeBottomSheet(
        selectedAmountType: selected,
        bookingType: bookingType,
        onChanged: onChanged,
      ),
    );
  }
}
