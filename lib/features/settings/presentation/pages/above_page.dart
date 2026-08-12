import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../l10n/app_localizations.dart';

class AbovePage extends StatefulWidget {
  const AbovePage({super.key});

  @override
  State<AbovePage> createState() => _AbovePageState();
}

class _AbovePageState extends State<AbovePage> {
  String appVersion = '...';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version; // Holt die App Version aus der pubspec.yaml
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('${t.translate('above')} ${t.translate('app_name')}'),
      ),
      body: ListView(
        children: [
          Card(
            child: Column(
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/icons/app_icon_circle.png',
                    width: 220.0,
                    height: 220.0,
                    fit: BoxFit.cover,
                  ),
                ),
                Text(
                  t.translate('current_app_version'),
                  style: TextStyle(fontSize: 18.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'V $appVersion',
                    style: const TextStyle(fontSize: 18.0),
                  ),
                ),
                Text(
                  t.translate('current_database_version'),
                  style: const TextStyle(fontSize: 18.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'V 1.0.0',
                    style: const TextStyle(fontSize: 18.0),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12.0, bottom: 24.0),
            child: Card(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      t.translate('app_developer'),
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                  Text('Marcel Geirhos'),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('${t.translate('contact')} ${t.translate('email')}: Marcel.Geirhos@gmail.com'),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
            child: Center(
              child: Text(t.translate('made_in_germany')),
            ),
          ),
          Icon(Icons.favorite_rounded, color: Colors.red),
        ],
      ),
    );
  }
}
