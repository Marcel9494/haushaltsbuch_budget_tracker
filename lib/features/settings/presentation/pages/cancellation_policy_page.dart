import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../l10n/app_localizations.dart';

class CancellationPolicyPage extends StatelessWidget {
  const CancellationPolicyPage({super.key});

  Future<void> _sendWithdrawalEmail(BuildContext context) async {
    final t = AppLocalizations.of(context);
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? '';

    final subject = t.translate('cancellation_email_subject');

    final body = t.translate('cancellation_policy_form_description').replaceAll('{email}', email);

    final Uri emailUri = Uri.parse(
      'mailto:marcel.geirhos@gmail.com'
      '?subject=${Uri.encodeComponent(subject)}'
      '&body=${Uri.encodeComponent(body)}',
    );

    try {
      final launched = await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${t.translate('open_email_provider_error')} Marcel.Geirhos@gmail.com.'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${t.translate('open_email_provider_error')} Marcel.Geirhos@gmail.com.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('right_of_withdrawal')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle(
                context,
                t.translate('right_of_withdrawal'),
              ),
              _paragraph(context, 'right_of_withdrawal_content_1'),
              _paragraph(context, 'right_of_withdrawal_content_2'),
              _sectionTitle(context, 'right_of_withdrawal_content_3'),
              _paragraph(context, 'right_of_withdrawal_content_4'),
              _contactCard(context),
              _paragraph(context, 'right_of_withdrawal_content_5'),
              _paragraph(context, 'right_of_withdrawal_content_6'),
              _sectionTitle(context, 'right_of_withdrawal_content_7'),
              _paragraph(context, 'right_of_withdrawal_content_8'),
              _paragraph(context, 'right_of_withdrawal_content_9'),
              _sectionTitle(context, 'cancellation_policy_form'),
              _paragraph(context, 'right_of_withdrawal_content_10'),
              _formBox(context),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.translate('cancellation_directly_via_email'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(t.translate('cancellation_directly_via_email_description')),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => _sendWithdrawalEmail(context),
                          icon: const Icon(Icons.email_outlined),
                          label: Text(t.translate('declare_revocation_via_email')),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.cyanAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('${t.translate('status')}: ${t.translate('right_of_withdrawal_date')}'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    final t = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(
        top: 20,
        bottom: 10,
      ),
      child: Text(
        t.translate(title),
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _paragraph(BuildContext context, String text) {
    final t = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        t.translate(text),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
      ),
    );
  }

  Widget _contactCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Marcel Geirhos / [Unternehmensname]',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Gartenstraße 8, 73550 Waldstetten',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'E-Mail: Marcel.Geirhos@gmail.com',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _formBox(BuildContext context) {
    final t = AppLocalizations.of(context);
    final String formText = t.translate('cancellation_policy_form_description');

    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t.translate('cancellation_policy_form'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  tooltip: t.translate('copy'),
                  icon: const Icon(Icons.copy),
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: formText),
                    );

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(t.translate('copied_content_sucessfully')),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(formText),
          ],
        ),
      ),
    );
  }
}
