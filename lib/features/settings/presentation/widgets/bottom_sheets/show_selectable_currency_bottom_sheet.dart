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

  static Future<String?> show(BuildContext context, {required String title}) {
    final t = AppLocalizations.of(context);
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
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
                      style: const TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 28.0,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: supportedCurrencies.length,
                  itemBuilder: (context, index) {
                    final currency = supportedCurrencies[index];

                    return ListTile(
                      leading: Flag.fromString(
                        currency.locale.split('_').last,
                        height: 32.0,
                        width: 46.0,
                        borderRadius: 8.0,
                      ),
                      title: Text(
                        currency.code,
                        style: const TextStyle(
                          fontSize: 18.0,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        currency.name,
                        style: const TextStyle(
                          fontSize: 14.0,
                          color: Colors.white60,
                        ),
                      ),
                      trailing: Text(
                        currency.symbol,
                        style: const TextStyle(
                          fontSize: 24.0,
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(
                          context,
                          currency.code,
                        );
                      },
                    );
                  },
                  separatorBuilder: (_, __) => const Divider(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
