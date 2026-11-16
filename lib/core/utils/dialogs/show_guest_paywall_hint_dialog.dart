import 'package:flutter/material.dart';

import '../../../data/enums/guest_paywall_hint_choice.dart';
import '../../../l10n/app_localizations.dart';

// Weist Gäste vor dem Öffnen der Paywall darauf hin, dass sie gerade Premium
// freischalten möchten, ihre Daten aber keinem Konto zugeordnet sind und bei
// einem Gerätewechsel verloren gehen. Der Warnhinweis wird dezent rot hervorgehoben.
// Schließt der Benutzer den Dialog ohne Auswahl, wird cancel zurückgegeben.
Future<GuestPaywallHintChoice> showGuestPaywallHintDialog(BuildContext context) async {
  final t = AppLocalizations.of(context);
  final Color warningColor = Theme.of(context).brightness == Brightness.dark ? Colors.red.shade200 : Colors.red.shade800;

  final GuestPaywallHintChoice? choice = await showDialog<GuestPaywallHintChoice>(
    context: context,
    builder: (context) => AlertDialog(
      scrollable: true,
      title: Text(t.translate('guest_paywall_hint_title')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.translate('guest_paywall_hint_intro')),
          const SizedBox(height: 12.0),
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: warningColor.withAlpha(15),
              border: Border.all(color: warningColor.withAlpha(90)),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              t.translate('guest_paywall_hint_text'),
              style: TextStyle(color: warningColor),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.grey),
          onPressed: () => Navigator.of(context).pop(GuestPaywallHintChoice.continueAsGuest),
          child: Text(t.translate('continue_as_guest')),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black87,
            backgroundColor: Colors.cyanAccent,
          ),
          onPressed: () => Navigator.of(context).pop(GuestPaywallHintChoice.upgradeAccount),
          child: Text(t.translate('upgrade_account')),
        ),
      ],
    ),
  );
  return choice ?? GuestPaywallHintChoice.cancel;
}
