import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haushaltsbuch_budget_tracker/l10n/app_localizations.dart';

class ErrorText extends StatelessWidget {
  final String errorMessage;

  const ErrorText({
    super.key,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.circleExclamation,
            size: 50.0,
            color: Colors.redAccent,
          ),
          SizedBox(height: 16.0),
          Text(
            t.translate(errorMessage),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
