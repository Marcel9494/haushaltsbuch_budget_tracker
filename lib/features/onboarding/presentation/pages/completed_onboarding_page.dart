import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haushaltsbuch_budget_tracker/core/page_arguments/home_page_arguments.dart';
import 'package:haushaltsbuch_budget_tracker/data/helper_models/onboarding_models.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../blocs/on_boarding/on_boarding_bloc.dart';
import '../../../../blocs/on_boarding/on_boarding_event.dart';
import '../../../../blocs/on_boarding/on_boarding_state.dart';
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
  final List<Category> startCategories = [];
  final List<Account> startAccounts = [];
  final List<DashboardElement> startDashboardElements = [];

  @override
  void initState() {
    super.initState();
    startCategories.addAll(
      expensesStartCategories.where((startCategory) => startCategory.isSelected).map(
            (startCategory) => Category(
              userId: Supabase.instance.client.auth.currentUser!.id,
              categoryName: startCategory.categoryName,
              categoryType: startCategory.categoryType,
            ),
          ),
    );

    startCategories.addAll(
      revenueStartCategories.where((startCategory) => startCategory.isSelected).map(
            (startCategory) => Category(
              userId: Supabase.instance.client.auth.currentUser!.id,
              categoryName: startCategory.categoryName,
              categoryType: startCategory.categoryType,
            ),
          ),
    );

    startAccounts.addAll(
      allStartAccounts.where((startAccount) => startAccount.isSelected).map(
            (startAccount) => Account(
              userId: Supabase.instance.client.auth.currentUser!.id,
              name: startAccount.accountName,
              accountType: startAccount.accountType,
              balance: startAccount.balance,
            ),
          ),
    );

    startDashboardElements.addAll(
      selectedStartDashboardElements.map(
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OnboardingBloc>().add(StartOnboarding(
            startCategories: startCategories,
            startAccounts: startAccounts,
            startDashboardElements: startDashboardElements,
          ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
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
  }
}
