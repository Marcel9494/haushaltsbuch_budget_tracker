import 'package:flutter/material.dart';
import 'package:haushaltsbuch_budget_tracker/features/settings/presentation/widgets/bottom_sheets/selectable_bottom_sheet.dart';

class ShowSelectableBottomSheet {
  static Future<void> show(
    BuildContext context, {
    required String title,
    required ValueChanged<Locale> onChanged,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => SelectableBottomSheet(
        title: title,
        onChanged: onChanged,
      ),
    );
  }
}
