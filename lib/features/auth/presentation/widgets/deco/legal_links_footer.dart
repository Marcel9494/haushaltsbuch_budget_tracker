import 'package:flutter/material.dart';
import 'package:haushaltsbuch_budget_tracker/l10n/app_localizations.dart';

import '../../../../../core/consts/route_consts.dart';
import '../../../../../core/utils/legal_helper.dart';
import '../../../../shared/presentation/widgets/deco/footer_link.dart';
import '../../../../shared/presentation/widgets/deco/point_separator.dart';

class LegalLinksFooter extends StatelessWidget {
  const LegalLinksFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        FooterLink(
          text: t.translate('only_terms_of_use'),
          onPressed: () {
            openTermsOfUse(context);
          },
        ),
        PointSeparator(),
        FooterLink(
          text: t.translate('short_privacy_policy'),
          onPressed: () {
            openPrivacyPolicy(context);
          },
        ),
        PointSeparator(),
        FooterLink(
          text: t.translate('imprint'),
          onPressed: () {
            Navigator.pushNamed(
              context,
              imprintRoute,
            );
          },
        ),
      ],
    );
  }
}
