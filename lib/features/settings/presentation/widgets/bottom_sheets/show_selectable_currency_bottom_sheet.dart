import 'package:flag/flag_widget.dart';
import 'package:flutter/material.dart';

import '../../../../../data/helper_models/currency.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../shared/presentation/widgets/deco/bottom_sheet_line.dart';

class ShowSelectableCurrencyBottomSheet {
  static const List<Currency> supportedCurrencies = [
    Currency(
      code: 'EUR',
      symbol: '€',
      name: 'Euro',
      locale: 'eu_EU',
    ),
    Currency(
      code: 'USD',
      symbol: '\$',
      name: 'United States Dollar',
      locale: 'en_US',
    ),
  ];

  static Future<void> show(
    BuildContext context, {
    required String title,
    required ValueChanged<String> onChanged,
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
                      style: const TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 28.0),
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
                      leading: Flag.fromString(
                        supportedCurrencies[index].locale.split('_').last,
                        height: 32.0,
                        width: 46.0,
                        borderRadius: 8.0,
                      ),
                      title: Text(
                        supportedCurrencies[index].code,
                        style: TextStyle(fontSize: 18.0, color: Colors.white),
                      ),
                      subtitle: Text(
                        supportedCurrencies[index].name,
                        style: TextStyle(fontSize: 14.0, color: Colors.white60),
                      ),
                      trailing: Text(
                        supportedCurrencies[index].symbol,
                        style: TextStyle(fontSize: 24.0, color: Colors.white),
                      ),
                      onTap: () {
                        onChanged(supportedCurrencies[index].code);
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
