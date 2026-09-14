import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openPrivacyPolicy(BuildContext context) async {
  final uri =
      Uri.parse('https://marcel9494.github.io/haushaltsbuch_budget_tracker/privacyPolicy_${Localizations.localeOf(context).languageCode}.html');

  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw Exception('privacy_policy_open_error');
  }
}

Future<void> openTermsOfUse(BuildContext context) async {
  final uri =
      Uri.parse('https://marcel9494.github.io/haushaltsbuch_budget_tracker/terms_of_use_${Localizations.localeOf(context).languageCode}.html');

  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw Exception('terms_of_use_open_error');
  }
}
