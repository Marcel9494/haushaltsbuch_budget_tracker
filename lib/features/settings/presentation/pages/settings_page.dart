import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haushaltsbuch_budget_tracker/blocs/user/user_event.dart';
import 'package:haushaltsbuch_budget_tracker/data/repositories/user_repository.dart';
import 'package:haushaltsbuch_budget_tracker/features/settings/presentation/widgets/cards/settings_card.dart';
import 'package:haushaltsbuch_budget_tracker/features/settings/presentation/widgets/deco/settings_title.dart';
import 'package:haushaltsbuch_budget_tracker/features/settings/presentation/widgets/dialogs/show_user_logout_dialog.dart';
import 'package:haushaltsbuch_budget_tracker/l10n/app_localizations.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../blocs/account/account_bloc.dart';
import '../../../../blocs/booking/booking_bloc.dart';
import '../../../../blocs/budget/budget_bloc.dart';
import '../../../../blocs/category/category_bloc.dart';
import '../../../../blocs/dashboard_element/dashboard_element_bloc.dart';
import '../../../../blocs/goal/goal_bloc.dart';
import '../../../../blocs/user/user_bloc.dart';
import '../../../../blocs/user/user_state.dart';
import '../../../../core/consts/route_consts.dart';
import '../../../../core/page_arguments/issue_page_arguments.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../../core/utils/dialogs/exchange_rate_dialog.dart';
import '../../../../core/utils/exchange_rate_service.dart';
import '../../../../core/utils/legal_helper.dart';
import '../../../../data/repositories/account_repository.dart';
import '../../../../data/repositories/booking_repository.dart';
import '../../../../data/repositories/budget_repository.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/repositories/dashboard_element_repository.dart';
import '../../../../data/repositories/goal_repository.dart';
import '../../../../main.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../shared/presentation/widgets/deco/circular_loading_indicator.dart';
import '../../../shared/presentation/widgets/deco/error_text.dart';
import '../widgets/bottom_sheets/show_selectable_country_bottom_sheet.dart';
import '../widgets/bottom_sheets/show_selectable_currency_bottom_sheet.dart';
import '../widgets/dialogs/show_delete_user_account_dialog.dart';
import '../widgets/dialogs/show_guest_logout_dialog.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future<void> _logout() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    bool confirmed = false;

    final isAnonymous = user?.isAnonymous ?? false;
    if (isAnonymous == true) {
      confirmed = await showGuestLogoutDialog(context);
    } else {
      confirmed = await showUserLogoutDialog(context);
    }

    if (confirmed == true) {
      await supabase.auth.signOut();
    }
  }

  Future<void> _deleteUserAccount() async {
    bool confirmed = false;

    confirmed = await showDeleteUserAccountDialog(context);
    if (confirmed == true) {
      UserRepository().deleteUserAccount();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final currentUser = Supabase.instance.client.auth.currentUser!;
    return BlocProvider(
      create: (context) => UserBloc(UserRepository(), BookingRepository(), AccountRepository())..add(LoadUser(userId: currentUser.id)),
      child: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserAmountsWithExchangeRateUpdated) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: userBloc),
                    BlocProvider(create: (context) => BookingBloc(BookingRepository(), AccountRepository())),
                    BlocProvider(create: (context) => DashboardElementBloc(DashboardElementRepository())),
                    BlocProvider(create: (context) => CategoryBloc(CategoryRepository())),
                    BlocProvider(create: (context) => AccountBloc(AccountRepository())),
                    BlocProvider(create: (context) => BudgetBloc(BudgetRepository())),
                    BlocProvider(create: (context) => GoalBloc(GoalRepository())),
                  ],
                  child: HomePage(currentPageIndex: 0),
                ),
              ),
              (route) => false,
            );
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const SettingsPage(),
              ),
            );
          }
        },
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state is UserLoading) {
              return CircularLoadingIndicator();
            } else if (state is UserLoaded) {
              return Scaffold(
                appBar: AppBar(title: Text(t.translate('settings'))),
                body: SingleChildScrollView(
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SettingsTitle(title: 'account_settings'),
                        SettingsCard(
                          leading: CountryFlag.fromCountryCode(
                            state.user.locale.toString().split('_').last,
                            theme: const ImageTheme(
                              shape: Circle(),
                              width: 24.0,
                              height: 24.0,
                            ),
                          ),
                          title: '${t.translate('change_language')}: ${t.translate(state.user.locale.languageCode)}',
                          onTap: () => ShowSelectableCountryBottomSheet.show(
                            context,
                            title: 'change_language',
                            onChanged: (Locale newLocale) {
                              MyApp.of(context)?.setLocale(newLocale);
                              context.read<UserBloc>().add(UpdateUserLocale(userId: currentUser.id, locale: newLocale));
                            },
                          ),
                        ),
                        SettingsCard(
                          leading: Icon(Icons.currency_exchange_rounded),
                          title: '${t.translate('change_currency')}: ${state.user.currencyCode}',
                          onTap: () async {
                            final newCurrencyCode = await ShowSelectableCurrencyBottomSheet.show(
                              context,
                              title: 'change_currency',
                            );

                            final exchangeRate = await ExchangeRateService.getValidRate(
                              fromCurrency: state.user.currencyCode,
                              toCurrency: newCurrencyCode!,
                            );
                            if (exchangeRate == null) {
                              return;
                            }

                            final bool shouldApplyExchangeRate = await ExchangeRateDialog.show(
                              context,
                              fromCurrency: state.user.currencyCode,
                              toCurrency: newCurrencyCode,
                              exchangeRate: exchangeRate,
                            );

                            CurrencyHelper.instance.setCurrency(newCurrencyCode);
                            context.read<UserBloc>().add(UpdateUserCurrency(
                                  userId: currentUser.id,
                                  currencyCode: newCurrencyCode,
                                ));
                            if (shouldApplyExchangeRate) {
                              context.read<UserBloc>().add(UpdateUserAmountsWithExchangeRate(
                                    userId: currentUser.id,
                                    exchangeRate: exchangeRate,
                                  ));
                            }
                          },
                        ),
                        currentUser.isAnonymous
                            ? SizedBox.shrink()
                            : SettingsCard(
                                leading: Icon(Icons.email_rounded),
                                title: t.translate('change_email'),
                                onTap: () => Navigator.pushNamed(context, changeEmailRoute),
                              ),
                        currentUser.isAnonymous || currentUser.identities?[0].provider != 'email'
                            ? SizedBox.shrink()
                            : SettingsCard(
                                leading: Icon(Icons.lock_reset_rounded),
                                title: t.translate('change_password'),
                                onTap: () => Navigator.pushNamed(context, changePasswordRoute),
                              ),
                        currentUser.isAnonymous
                            ? SettingsCard(
                                leading: Icon(Icons.workspace_premium_rounded),
                                title: t.translate('upgrade_account'),
                                onTap: () => Navigator.pushNamed(context, upgradeAccountRoute),
                              )
                            : SizedBox.shrink(),
                        SettingsTitle(title: 'general'),
                        SettingsCard(
                          leading: Icon(Icons.info_outline_rounded),
                          title: t.translate('over_the_app'),
                          onTap: () {
                            Navigator.pushNamed(context, aboveRoute);
                          },
                        ),
                        SettingsCard(
                          leading: Icon(Icons.feedback_rounded),
                          title: t.translate('give_feedback'),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              issueRoute,
                              arguments: IssuePageArguments(
                                milestoneTitle: 'User: Feedback',
                                label: 'user feedback',
                                successMessage: 'feedback_sended_successfully',
                                title: 'give_feedback',
                                description: 'feedback_description',
                                longDescriptionTitle: 'feedback_long_description_title',
                              ),
                            );
                          },
                        ),
                        SettingsCard(
                          leading: Icon(Icons.bug_report_rounded),
                          title: t.translate('bug_report'),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              issueRoute,
                              arguments: IssuePageArguments(
                                milestoneTitle: 'User: Bug Report',
                                label: 'user bug report',
                                successMessage: 'bug_report_sended_successfully',
                                title: 'bug_report',
                                description: 'bug_report_description',
                                longDescriptionTitle: 'bug_report_long_description_title',
                              ),
                            );
                          },
                        ),
                        SettingsCard(
                          leading: Icon(Icons.assignment_rounded),
                          title: t.translate('manage_subscription'),
                          onTap: () async {
                            await RevenueCatUI.presentCustomerCenter();
                          },
                        ),
                        SettingsTitle(title: 'legal'),
                        SettingsCard(
                          leading: Icon(Icons.description_rounded),
                          title: t.translate('imprint'),
                          onTap: () {
                            Navigator.pushNamed(context, imprintRoute);
                          },
                        ),
                        SettingsCard(
                          leading: Icon(Icons.security_rounded),
                          title: t.translate('privacy_policy'),
                          onTap: () {
                            openPrivacyPolicy(context);
                          },
                        ),
                        SettingsCard(
                          leading: Icon(Icons.receipt_long_rounded),
                          title: t.translate('terms_of_use'),
                          onTap: () {
                            openTermsOfUse(context);
                          },
                        ),
                        SettingsCard(
                          leading: Icon(Icons.assignment_rounded),
                          title: t.translate('right_of_withdrawal_information'),
                          onTap: () {
                            Navigator.pushNamed(context, cancellationPolicyRoute);
                          },
                        ),
                        SettingsCard(
                          leading: Icon(Icons.copyright_rounded),
                          title: t.translate('licenses'),
                          onTap: () {
                            showLicensePage(
                              context: context,
                              applicationName: t.translate('app_name'),
                              applicationVersion: '1.0.0',
                            );
                          },
                        ),
                        SettingsTitle(title: 'further'),
                        SettingsCard(
                          leading: Icon(Icons.logout_rounded),
                          title: t.translate('logout'),
                          onTap: () => _logout(),
                        ),
                        SettingsCard(
                          leading: Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
                          title: t.translate('delete_user_account'),
                          onTap: () => _deleteUserAccount(),
                          color: Colors.redAccent,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else if (state is UserError) {
              return ErrorText(errorMessage: state.message);
            }
            return SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
