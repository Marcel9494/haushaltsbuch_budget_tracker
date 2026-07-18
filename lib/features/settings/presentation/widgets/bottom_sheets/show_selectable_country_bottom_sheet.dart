import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../shared/presentation/widgets/deco/bottom_sheet_line.dart';

class ShowSelectableCountryBottomSheet {
  static Future<void> show(
    BuildContext context, {
    required String title,
    required ValueChanged<Locale> onChanged,
  }) {
    final t = AppLocalizations.of(context);
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BottomSheetLine(),
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
                        t.translate(AppLocalizations.supportedLocales[index].toString()),
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
      ),
    );
  }
}
