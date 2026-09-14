import 'package:flutter/material.dart';
import 'package:haushaltsbuch_budget_tracker/core/utils/legal_helper.dart';

import '../../../l10n/app_localizations.dart';

Future<bool> showTermsOfUseDialog(BuildContext context) async {
  final t = AppLocalizations.of(context);
  bool accepted = false;

  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              t.translate('only_terms_of_use'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.translate('read_terms_of_use'),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () {
                    openTermsOfUse(context);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 20,
                          color: Colors.cyanAccent,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          t.translate('view_terms_of_use'),
                          style: TextStyle(
                            color: Colors.cyanAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  value: accepted,
                  onChanged: (value) {
                    setState(() {
                      accepted = value ?? false;
                    });
                  },
                  activeColor: Colors.cyanAccent,
                  checkColor: Colors.black87,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(t.translate('accept_terms_of_use')),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text(t.translate('cancel'), style: TextStyle(color: Colors.grey)),
              ),
              FilledButton(
                onPressed: accepted
                    ? () {
                        Navigator.of(context).pop(true);
                      }
                    : null,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) {
                      if (states.contains(WidgetState.disabled)) {
                        return Colors.grey.shade800;
                      }
                      return Colors.cyanAccent;
                    },
                  ),
                ),
                child: Text(t.translate('accept')),
              ),
            ],
          );
        },
      );
    },
  );
  return result ?? false;
}
