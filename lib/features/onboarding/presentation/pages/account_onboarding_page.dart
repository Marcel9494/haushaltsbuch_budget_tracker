import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../../core/consts/animation_consts.dart';
import '../../../../core/consts/route_consts.dart';
import '../../../../core/utils/dialogs/show_add_account_dialog.dart';
import '../../../../data/enums/account_type.dart';
import '../../../../data/enums/onboarding_progressbar_type.dart';
import '../../../../data/helper_models/onboarding_models.dart';
import '../../../../data/helper_models/start_account.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../bookings/presentation/widgets/buttons/add_button.dart';
import '../widgets/cards/onboarding_description_card.dart';
import '../widgets/cards/selectable_account_card.dart';
import '../widgets/deco/onboarding_progress_bar.dart';
import '../widgets/navigation/onboarding_navigation.dart';

class AccountOnboardingPage extends StatefulWidget {
  const AccountOnboardingPage({super.key});

  @override
  State<AccountOnboardingPage> createState() => _AccountOnboardingPageState();
}

class _AccountOnboardingPageState extends State<AccountOnboardingPage> {
  final TextEditingController _accountNameController = TextEditingController();
  final ScrollController _accountScrollController = ScrollController();

  void createNewStartAccount(String categoryName) {
    setState(() {
      if (allStartAccounts.any((account) => account.accountName == _accountNameController.text)) {
        allStartAccounts.firstWhere((account) => account.accountName == _accountNameController.text).isSelected = true;
      } else {
        allStartAccounts.add(StartAccount(
          isSelected: true,
          accountName: _accountNameController.text,
          accountType: AccountType.noAccountType,
          balance: 0.0,
        ));
        _scrollToListEnd();
      }
    });
  }

  void _scrollToListEnd() {
    final controller = _accountScrollController;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.animateTo(
        controller.position.maxScrollExtent,
        duration: const Duration(milliseconds: 1500),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            OnboardingProgressBar(
              progressBar1State: OnboardingProgressbarType.completed,
              progressBar2State: OnboardingProgressbarType.completed,
              progressBar3State: OnboardingProgressbarType.active,
            ),
            OnboardingDescriptionCard(
              title: t.translate('select_accounts'),
              descriptionText1: t.translate('select_accounts_description'),
              descriptionText2: t.translate('change_accounts_later'),
            ),
            Expanded(
              child: AnimationLimiter(
                child: ListView.builder(
                  controller: _accountScrollController,
                  itemCount: allStartAccounts.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: listAnimationDurationInMs),
                      child: SlideAnimation(
                        verticalOffset: 40.0,
                        child: FadeInAnimation(
                          child: SelectableAccountCard(
                            account: allStartAccounts[index],
                            onPressed: () => setState(() {
                              allStartAccounts[index].isSelected = !allStartAccounts[index].isSelected;
                            }),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.center,
              child: AddButton(
                text: t.translate('create_additional_account'),
                onPressed: () => showAddAccountDialog(
                  context,
                  _accountNameController,
                  (name) async {
                    createNewStartAccount(name);
                  },
                ),
              ),
            ),
            OnboardingNavigation(
              nextRoute: completedOnboardingRoute,
              nextButtonText: 'complete',
              showBackRoute: true,
              backRoute: dashboardOnboardingRoute,
              backButtonText: 'back',
            ),
          ],
        ),
      ),
    );
  }
}
