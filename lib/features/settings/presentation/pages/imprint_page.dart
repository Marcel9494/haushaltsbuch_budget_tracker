import 'package:flutter/material.dart';
import 'package:haushaltsbuch_budget_tracker/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class ImprintPage extends StatelessWidget {
  const ImprintPage({super.key});

  Future<void> _launchEuropeCommissionSite({required String url}) async {
    try {
      bool launched = await launchUrl(Uri.parse(url));
      if (launched == false) {
        launchUrl(Uri.parse(url));
      }
    } catch (e) {
      launchUrl(Uri.parse(url));
    }
  }

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
            // TODO hier weitermachen und Übersetzungen hinzufügen
            Text(t.translate('information_in_accordance_with')),
            Text('Marcel Geirhos'),
            Text('Gartenstraße 8, 73550, Waldstetten'),
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 4.0),
              child: Text('${t.translate('contact')}:', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
            ),
            Text('${t.translate('phone')}: +49 176 30721919'),
            Text('${t.translate('email')}: Marcel.Geirhos@gmail.com'),
            Text(t.translate('no_ustidnr')),
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Text('${t.translate('responsible_for_content')}:'),
            ),
            Text('Marcel Geirhos'),
            Text('Gartenstraße 8, 73550, Waldstetten'),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Text('${t.translate('status')}: 10.08.2026'),
            ),
          ],
        ),
      ),
    );
  }
}
