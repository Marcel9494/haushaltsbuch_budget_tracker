import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';

class EmptyList extends StatelessWidget {
  final String text;
  final Widget icon;

  const EmptyList({
    super.key,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              SizedBox(height: 12.0),
              Text(
                t.translate(text),
                style: TextStyle(fontSize: 16.0, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
