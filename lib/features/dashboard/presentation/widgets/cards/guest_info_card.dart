import 'package:flutter/material.dart';
import 'package:haushaltsbuch_budget_tracker/core/consts/route_consts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../l10n/app_localizations.dart';

class GuestInfoCard extends StatefulWidget {
  const GuestInfoCard({super.key});

  @override
  _GuestInfoCardState createState() => _GuestInfoCardState();
}

class _GuestInfoCardState extends State<GuestInfoCard> {
  bool _showInfo = false;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Supabase.instance.client.auth.currentUser!.isAnonymous
        ? GestureDetector(
            onTap: () {
              setState(() {
                _showInfo = !_showInfo;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Card(
                child: ClipPath(
                  clipper: ShapeBorderClipper(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(left: BorderSide(color: Colors.cyanAccent, width: 3.0)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                t.translate('guest_info_title'),
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(t.translate('more_info'), style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
                                  SizedBox(width: 4),
                                  Icon(_showInfo ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.cyanAccent),
                                ],
                              ),
                            ],
                          ),
                          // Wird ausgeklappt
                          if (_showInfo) ...[
                            SizedBox(height: 8.0),
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
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        : SizedBox.shrink();
  }
}
