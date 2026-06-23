import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../../blocs/onboarding_account/onboarding_account_bloc.dart';
import '../../../../core/consts/animation_consts.dart';
import '../../../../core/consts/route_consts.dart';
import '../../../../core/utils/dialogs/show_add_account_dialog.dart';
import '../../../../data/enums/account_type.dart';
import '../../../../data/enums/onboarding_progressbar_type.dart';
import '../../../../data/models/onboarding_account.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../bookings/presentation/widgets/buttons/add_button.dart';
import '../../../shared/presentation/widgets/deco/circular_loading_indicator.dart';
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

  @override
  void initState() {
    super.initState();
    context.read<OnboardingAccountBloc>().add(LoadOnboardingAccounts(context: context));
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
    return BlocBuilder<OnboardingAccountBloc, OnboardingAccountState>(
      builder: (context, state) {
        if (state is OnboardingAccountLoading) {
          return CircularLoadingIndicator();
        } else if (state is OnboardingAccountsLoaded) {
          print('Test 2');
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
                        itemCount: state.onboardingAccounts.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: listAnimationDurationInMs),
                            child: SlideAnimation(
                              verticalOffset: 40.0,
                              child: FadeInAnimation(
                                child: SelectableAccountCard(
                                  account: state.onboardingAccounts[index],
                                  onPressed: () => context.read<OnboardingAccountBloc>().add(SelectOnboardingAccount(
                                        onboardingAccounts: state.onboardingAccounts,
                                        updatingOnboardingAccount: state.onboardingAccounts[index],
                                      )),
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
                          context.read<OnboardingAccountBloc>().add(AddOnboardingAccount(
                                onboardingAccounts: state.onboardingAccounts,
                                onboardingAccount:
                                    OnboardingAccount(accountName: name, accountType: AccountType.account, isSelected: true, balance: 0.0),
                              ));
                          print('Test');
                          _scrollToListEnd();
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
        } else if (state is OnboardingAccountError) {
          return Center(child: Text(t.translate(state.message)));
        }
        return SizedBox.shrink();
      },
    );
  }
}
