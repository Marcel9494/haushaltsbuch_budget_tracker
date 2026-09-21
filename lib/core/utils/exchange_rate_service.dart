import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ExchangeRateService {
  static const String _ratesKey = 'exchange_rates';

  // Returns the current exchange rate.
  // First tries to use a cached rate. If no valid cached rate exists,
  // the rate is fetched from the API and cached.
  static Future<double?> getValidRate({required String fromCurrency, required String toCurrency}) async {
    if (fromCurrency == toCurrency) {
      return 1.0;
    }

    final cachedRate = await _getSavedRate(fromCurrency: fromCurrency, toCurrency: toCurrency);
    if (cachedRate != null && !_isExpired(cachedRate)) {
      return cachedRate.rate;
    }

    final apiRate = await _fetchRate(fromCurrency: fromCurrency, toCurrency: toCurrency);
    if (apiRate == null) {
      return cachedRate?.rate;
    }
    await saveRate(fromCurrency: fromCurrency, toCurrency: toCurrency, rate: apiRate);
    return apiRate;
  }

  // Fetches the exchange rate directly from the API.
  static Future<double?> _fetchRate({required String fromCurrency, required String toCurrency}) async {
    try {
      final uri = Uri.parse('https://api.frankfurter.app/latest?from=$fromCurrency&to=$toCurrency');
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final rates = data['rates'] as Map<String, dynamic>?;
      if (rates == null) {
        return null;
      }

      final rate = rates[toCurrency];
      if (rate is num) {
        return rate.toDouble();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // Saves an exchange rate locally.
  static Future<void> saveRate({required String fromCurrency, required String toCurrency, required double rate}) async {
    final prefs = await SharedPreferences.getInstance();
    final rates = _getRatesMap(prefs);
    final key = _createRateKey(fromCurrency: fromCurrency, toCurrency: toCurrency);

    rates[key] = {
      'rate': rate,
      'savedAt': DateTime.now().toIso8601String(),
    };
    await prefs.setString(_ratesKey, jsonEncode(rates));
  }

  // Returns the saved exchange rate.
  static Future<SavedExchangeRate?> _getSavedRate({required String fromCurrency, required String toCurrency}) async {
    final prefs = await SharedPreferences.getInstance();
    final rates = _getRatesMap(prefs);
    final key = _createRateKey(fromCurrency: fromCurrency, toCurrency: toCurrency);
    final data = rates[key];

    if (data is! Map<String, dynamic>) {
      return null;
    }

    final rate = data['rate'];
    final savedAt = data['savedAt'];
    if (rate is! num || savedAt is! String) {
      return null;
    }

    final date = DateTime.tryParse(savedAt);
    if (date == null) {
      return null;
    }
    return SavedExchangeRate(rate: rate.toDouble(), savedAt: date);
  }

  static Map<String, dynamic> _getRatesMap(SharedPreferences prefs) {
    final jsonString = prefs.getString(_ratesKey);
    if (jsonString == null) {
      return {};
    }

    try {
      final decoded = jsonDecode(jsonString);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {};
    } catch (_) {
      return {};
    }
  }

  static String _createRateKey({required String fromCurrency, required String toCurrency}) {
    return '${fromCurrency}_$toCurrency';
  }

  // Exchange rates are considered valid for 24 hours.
  static bool _isExpired(SavedExchangeRate rate) {
    return DateTime.now().difference(rate.savedAt).inHours >= 24;
  }
}

class SavedExchangeRate {
  final double rate;
  final DateTime savedAt;

  const SavedExchangeRate({
    required this.rate,
    required this.savedAt,
  });
}
