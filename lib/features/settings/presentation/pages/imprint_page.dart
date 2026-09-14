import 'package:flutter/material.dart';
import 'package:haushaltsbuch_budget_tracker/l10n/app_localizations.dart';

class ImprintPage extends StatelessWidget {
  const ImprintPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('imprint')),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(t.translate('imprint'), style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
            ),
            Text(t.translate('information_in_accordance_with')),
            Text(t.translate('app_owner')),
            Text(t.translate('app_owner_address')),
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 4.0),
              child: Text('${t.translate('contact')}:', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
            ),
            Text('${t.translate('phone')}: ${t.translate('app_owner_phone')}'),
            Text('${t.translate('email')}: ${t.translate('app_owner_email')}'),
            Text(t.translate('no_ustidnr')),
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Text('${t.translate('responsible_for_content')}:'),
            ),
            Text(t.translate('app_owner')),
            Text(t.translate('app_owner_address')),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Text('${t.translate('status')}: ${t.translate('imprint_date')}'),
            ),
          ],
        ),
      ),
    );
  }
}
