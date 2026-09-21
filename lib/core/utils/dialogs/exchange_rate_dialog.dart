import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class ExchangeRateDialog {
  static Future<bool> show(BuildContext context, {required String fromCurrency, required String toCurrency, required double exchangeRate}) async {
    final t = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(t.translate('apply_exchange_rate')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${t.translate('you_are_switching_from')} $fromCurrency ${t.translate('to')} $toCurrency.'),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.translate('current_exchange_rate'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '1 $fromCurrency = '
                      '${exchangeRate.toStringAsFixed(2)} $toCurrency',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(t.translate('exchange_rate_description')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(t.translate('keep')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(t.translate('convert')),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }
}
