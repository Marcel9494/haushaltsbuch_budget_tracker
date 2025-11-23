import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haushaltsbuch_budget_tracker/l10n/app_localizations.dart';

import '../../../../shared/presentation/widgets/list_tiles/selectable_list_tile.dart';
import '../../../data/enums/amount_type.dart';
import '../../../data/enums/booking_type.dart';

class AmountTypeBottomSheet extends StatelessWidget {
  final AmountType selectedAmountType;
  final BookingType bookingType;
  final ValueChanged<AmountType> onChanged;

  const AmountTypeBottomSheet({
    super.key,
    required this.selectedAmountType,
    required this.bookingType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${t.translate('amount_type')}:',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SelectableListTile(
              icon: FontAwesomeIcons.scaleUnbalanced,
              selected: selectedAmountType == AmountType.variable || selectedAmountType == AmountType.active,
              text: bookingType == BookingType.expense ? t.translate('variable') : t.translate('active'),
              onTap: () {
                final amountTypeResult = bookingType == BookingType.expense ? AmountType.variable : AmountType.active;
                onChanged(amountTypeResult);
                Navigator.pop(context);
              },
            ),
            Divider(),
            SelectableListTile(
              icon: FontAwesomeIcons.scaleUnbalancedFlip,
              selected: selectedAmountType == AmountType.fix || selectedAmountType == AmountType.passive,
              text: bookingType == BookingType.expense ? t.translate('fix') : t.translate('passive'),
              onTap: () {
                final amountTypeResult = bookingType == BookingType.expense ? AmountType.fix : AmountType.passive;
                onChanged(amountTypeResult);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
