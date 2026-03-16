import '../../data/models/account.dart';
import '../../data/models/category.dart';
import '../../data/models/dashboard_element.dart';

abstract class OnboardingEvent {}

class StartOnboarding extends OnboardingEvent {
  List<Category> startCategories;
  List<Account> startAccounts;
  List<DashboardElement> startDashboardElements;

  StartOnboarding({
    required this.startCategories,
    required this.startAccounts,
    required this.startDashboardElements,
  });
}
