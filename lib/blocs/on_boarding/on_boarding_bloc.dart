import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/account_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/dashboard_element_repository.dart';
import 'on_boarding_event.dart';
import 'on_boarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final CategoryRepository categoryRepository;
  final AccountRepository accountRepository;
  final DashboardElementRepository dashboardRepository;

  OnboardingBloc({
    required this.categoryRepository,
    required this.accountRepository,
    required this.dashboardRepository,
  }) : super(OnboardingState(step: 0, totalSteps: 3, finished: false, message: 'categories_are_created')) {
    on<StartOnboarding>(_onStart);
  }

  Future<void> _onStart(
    StartOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    await Future.delayed(const Duration(milliseconds: 400));

    await categoryRepository.createCategories(event.startCategories);
    emit(state.copyWith(step: 1, message: 'accounts_are_created'));

    await Future.delayed(const Duration(milliseconds: 1200));

    await accountRepository.createAccounts(event.startAccounts);
    emit(state.copyWith(step: 2, message: 'dashboard_elements_are_configured'));

    await Future.delayed(const Duration(milliseconds: 1200));

    await dashboardRepository.createDashboardElements(event.startDashboardElements);
    emit(state.copyWith(step: 3, finished: true, message: 'you_are_ready_to_go'));
  }
}
