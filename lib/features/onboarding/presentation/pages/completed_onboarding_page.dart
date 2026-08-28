import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haushaltsbuch_budget_tracker/core/page_arguments/home_page_arguments.dart';
import 'package:haushaltsbuch_budget_tracker/data/models/onboarding_dashboard_elements.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../blocs/on_boarding/on_boarding_bloc.dart';
import '../../../../blocs/on_boarding/on_boarding_event.dart';
import '../../../../blocs/on_boarding/on_boarding_state.dart';
import '../../../../blocs/onboarding_account/onboarding_account_bloc.dart';
import '../../../../blocs/onboarding_category/onboarding_category_bloc.dart';
import '../../../../core/consts/route_consts.dart';
import '../../../../core/utils/app_icon.dart';
import '../../../../data/models/account.dart';
import '../../../../data/models/category.dart';
import '../../../../data/models/dashboard_element.dart';
import '../../../../l10n/app_localizations.dart';

class CompletedOnboardingPage extends StatefulWidget {
  const CompletedOnboardingPage({super.key});

  @override
  State<CompletedOnboardingPage> createState() => _CompletedOnboardingPageState();
}

class _CompletedOnboardingPageState extends State<CompletedOnboardingPage> {
  final List<DashboardElement> startDashboardElements = [];
  bool _onboardingStarted = false;

  @override
  void initState() {
    super.initState();

    startDashboardElements.addAll(
      selectedOnboardingDashboardElements.map(
        (startDashboardElement) => DashboardElement(
          id: startDashboardElement.id,
          title: startDashboardElement.title,
          showValue: startDashboardElement.showValue,
          shortDescription: startDashboardElement.shortDescription,
          icon: startDashboardElement.icon,
          dashboardElementType: startDashboardElement.dashboardElementType,
          isSelected: startDashboardElement.isSelected,
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<OnboardingAccountBloc>().add(LoadOnboardingAccounts(context: context));
  }

  void _startOnboarding(OnboardingCategoriesLoaded categoryState, OnboardingAccountsLoaded accountState) {
    if (_onboardingStarted) {
      return;
    }

    _onboardingStarted = true;

    final userId = Supabase.instance.client.auth.currentUser!.id;

    final accounts = accountState.onboardingAccounts
        .where((account) => account.isSelected)
        .map(
          (account) => Account(
            userId: userId,
            name: account.accountName,
            accountType: account.accountType,
            balance: account.balance,
          ),
        )
        .toList();

    final categories = categoryState.onboardingCategories
        .where((category) => category.isSelected)
        .map(
          (category) => Category(
            userId: userId,
            categoryName: category.categoryName,
            categoryType: category.categoryType,
          ),
        )
        .toList();

    context.read<OnboardingBloc>().add(
          RunOnboarding(
            startCategories: categories,
            startAccounts: accounts,
            startDashboardElements: startDashboardElements,
            userId: userId,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return BlocBuilder<OnboardingCategoryBloc, OnboardingCategoryState>(
      builder: (context, categoryState) {
        if (categoryState is OnboardingCategoryError) {
          return Center(
            child: Text(t.translate(categoryState.message)),
          );
        }
        return BlocBuilder<OnboardingAccountBloc, OnboardingAccountState>(
          builder: (context, accountState) {
            if (accountState is OnboardingAccountError) {
              return Center(
                child: Text(t.translate(accountState.message)),
              );
            }
            if (categoryState is OnboardingCategoriesLoaded && accountState is OnboardingAccountsLoaded) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) {
                  return;
                }
                _startOnboarding(
                  categoryState,
                  accountState,
                );
              });
              return BlocConsumer<OnboardingBloc, OnboardingState>(
                listener: (context, state) async {
                  if (state.finished) {
                    await Future.delayed(
                      const Duration(milliseconds: 1500),
                    );

                    if (!context.mounted) {
                      return;
                    }

                    Navigator.of(context).pushNamedAndRemoveUntil(
                      homeRoute,
                      (route) => false,
                      arguments: HomePageArguments(0),
                    );
                  }
                },
                builder: (context, state) {
                  return Scaffold(
                    body: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          t.translate(state.message),
                          style: const TextStyle(
                            fontSize: 22.0,
                          ),
                        ),
                        const SizedBox(height: 32.0),
                        Center(
                          child: CircularPercentIndicator(
                            radius: 124.0,
                            lineWidth: 12.0,
                            animation: true,
                            percent: state.progress,
                            animateFromLastPercent: true,
                            center: AppIcon(),
                            circularStrokeCap: CircularStrokeCap.round,
                            progressColor: Colors.cyanAccent.shade700,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }
}
