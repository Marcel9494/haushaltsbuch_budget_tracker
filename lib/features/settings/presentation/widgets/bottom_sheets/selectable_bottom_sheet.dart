import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';

class SelectableBottomSheet extends StatelessWidget {
  final String title;
  final ValueChanged<Locale> onChanged;

  const SelectableBottomSheet({
    super.key,
    required this.title,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return SafeArea(
      child: SingleChildScrollView(
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
                    '${t.translate(title)}:',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: AppLocalizations.supportedLocales.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    leading: CountryFlag.fromCountryCode(
                      AppLocalizations.supportedLocales[index].countryCode!,
                      theme: const ImageTheme(
                        shape: RoundedRectangle(6),
                        width: 46,
                        height: 32,
                      ),
                    ),
                    title: Text(
                      t.translate(AppLocalizations.supportedLocales[index].languageCode),
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    trailing: Icon(Icons.keyboard_arrow_right_rounded, size: 24, color: Colors.white),
                    onTap: () {
                      final Locale locale = AppLocalizations.supportedLocales[index];
                      onChanged(locale);
                      Navigator.pop(context);
                    },
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Divider();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
