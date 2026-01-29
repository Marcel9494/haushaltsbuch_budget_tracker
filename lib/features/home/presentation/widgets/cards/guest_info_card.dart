import 'package:flutter/material.dart';
import 'package:haushaltsbuch_budget_tracker/core/consts/route_consts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../l10n/app_localizations.dart';

class GuestInfoCard extends StatelessWidget {
  const GuestInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Supabase.instance.client.auth.currentUser!.isAnonymous
        ? Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.translate('guest_info_text'),
                    textAlign: TextAlign.justify,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 8.0),
                  OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, upgradeAccountRoute),
                    child: Text(t.translate('upgrade_account')),
                  ),
                ],
              ),
            ),
          )
        : SizedBox.shrink();
  }
}
