import 'package:flutter/material.dart';

import '../../../data/enums/guest_paywall_hint_choice.dart';
import '../../../l10n/app_localizations.dart';

// Weist Gäste vor dem Öffnen der Paywall darauf hin, dass ihre Daten keinem Konto
// zugeordnet sind und bei einem Gerätewechsel verloren gehen.
// Schließt der Benutzer den Dialog ohne Auswahl, wird cancel zurückgegeben.
Future<GuestPaywallHintChoice> showGuestPaywallHintDialog(BuildContext context) async {
  final t = AppLocalizations.of(context);
  final GuestPaywallHintChoice? choice = await showDialog<GuestPaywallHintChoice>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(t.translate('guest_paywall_hint_title')),
      content: Text(t.translate('guest_paywall_hint_text')),
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
