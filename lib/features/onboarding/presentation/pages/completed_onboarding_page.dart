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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

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
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final categoryState = context.read<OnboardingCategoryBloc>().state;
    final accountState = context.read<OnboardingAccountBloc>().state;

    if (categoryState is OnboardingCategoriesLoaded && accountState is OnboardingAccountsLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<OnboardingBloc>().add(StartOnboarding(
              startCategories: categoryState.onboardingCategories
                  .where((startCategory) => startCategory.isSelected)
                  .map(
                    (startCategory) => Category(
                      userId: Supabase.instance.client.auth.currentUser!.id,
                      categoryName: startCategory.categoryName,
                      categoryType: startCategory.categoryType,
                    ),
                  )
                  .toList(),
              startAccounts: accountState.onboardingAccounts
                  .where((startAccount) => startAccount.isSelected)
                  .map(
                    (startAccount) => Account(
                      userId: Supabase.instance.client.auth.currentUser!.id,
                      name: startAccount.accountName,
                      accountType: startAccount.accountType,
                      balance: startAccount.balance,
                    ),
                  )
                  .toList(),
              startDashboardElements: startDashboardElements,
            ));
      });
      return BlocConsumer<OnboardingBloc, OnboardingState>(
        listener: (context, state) async {
          if (state.finished) {
            await Future.delayed(const Duration(milliseconds: 1800));
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
                  style: TextStyle(fontSize: 22.0),
                ),
                SizedBox(height: 32.0),
                Center(
                  child: CircularPercentIndicator(
                    radius: 124.0,
                    lineWidth: 12.0,
                    animation: true,
                    percent: state.progress,
                    animateFromLastPercent: true,
                    center: AppIcon(),
                    circularStrokeCap: CircularStrokeCap.round,
                    progressColor: Colors.green,
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else if (categoryState is OnboardingCategoryError) {
      return Center(child: Text(t.translate(categoryState.message)));
    } else if (accountState is OnboardingAccountError) {
      return Center(child: Text(t.translate(accountState.message)));
    }
    return SizedBox.shrink();
  }
}
