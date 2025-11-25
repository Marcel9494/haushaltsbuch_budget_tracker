import 'dart:ui';

import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:haushaltsbuch_budget_tracker/features/settings/presentation/widgets/cards/settings_card.dart';
import 'package:haushaltsbuch_budget_tracker/features/settings/presentation/widgets/deco/settings_title.dart';
import 'package:haushaltsbuch_budget_tracker/l10n/app_localizations.dart';

import '../widgets/bottom_sheets/show_selectable_bottom_sheet.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Locale _currentLocale = PlatformDispatcher.instance.locale;
  String _currentCurrency = 'Euro';

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.translate('settings'))),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SettingsTitle(title: 'account_settings'),
              SettingsCard(
                leading: CountryFlag.fromCountryCode(
                  _currentLocale.countryCode!,
                  theme: const ImageTheme(
                    shape: Circle(),
                    width: 24.0,
                    height: 24.0,
                  ),
                ),
                title: '${t.translate('change_language')}: ${t.translate(_currentLocale.languageCode)}',
                onTap: () => ShowSelectableBottomSheet.show(
                  context,
                  title: 'change_language',
                  onChanged: (Locale newLocale) {
                    setState(() {
                      _currentLocale = newLocale;
                    });
                  },
                ),
              ),
              SettingsCard(
                leading: Icon(Icons.currency_exchange_rounded),
                title: '${t.translate('change_currency')}: $_currentCurrency',
                onTap: () {},
              ),
              SettingsCard(
                leading: Icon(Icons.email_rounded),
                title: t.translate('change_email'),
                onTap: () {},
              ),
              SettingsCard(
                leading: Icon(Icons.lock_reset_rounded),
                title: t.translate('change_password'),
                onTap: () {},
              ),
              SettingsTitle(title: 'generally'),
              SettingsCard(
                leading: Icon(Icons.person_add_rounded),
                title: t.translate('send_invitation_link'),
                onTap: () {},
              ),
              SettingsCard(
                leading: Icon(Icons.star_rounded),
                title: t.translate('evaluate_app'),
                onTap: () {},
              ),
              SettingsTitle(title: 'legal'),
              SettingsCard(
                leading: Icon(Icons.security_rounded),
                title: t.translate('privacy_policy'),
                onTap: () {},
              ),
              SettingsCard(
                leading: Icon(Icons.description_rounded),
                title: t.translate('imprint'),
                onTap: () {},
              ),
              SettingsCard(
                leading: Icon(Icons.copyright_rounded),
                title: t.translate('credits'),
                onTap: () {},
              ),
              SettingsTitle(title: 'further'),
              SettingsCard(
                leading: Icon(Icons.logout_rounded),
                title: t.translate('logout'),
                onTap: () {},
              ),
              SettingsCard(
                leading: Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
                title: t.translate('delete_all_data'),
                onTap: () {},
                color: Colors.redAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
