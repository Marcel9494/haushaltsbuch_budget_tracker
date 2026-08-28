import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../blocs/account/account_bloc.dart';
import '../../../../../blocs/account/account_state.dart';
import '../../../../../core/utils/premium_service.dart';
import '../../../../../core/utils/slow_hero_animation.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../accounts/presentation/pages/create_account_page.dart';

class CreateAccountButton extends StatelessWidget {
  const CreateAccountButton({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return BlocSelector<AccountBloc, AccountState, int>(
      selector: (state) {
        if (state is AccountListLoaded) {
          return state.accounts.length;
        }
        return 0;
      },
      builder: (context, accountCount) {
        return Hero(
          tag: 'create_account_fab',
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: TextButton.icon(
              onPressed: () async {
                final allowed = await PremiumService.checkLimit(limitReached: accountCount >= 6);
                if (allowed == false) {
                  return;
                }

                Navigator.push(
                  context,
                  slowHeroRoute(
                    CreateAccountPage(),
                  ),
                );
              },
              label: Text(t.translate('create_account')),
            ),
          ),
        );
      },
    );
  }
}
