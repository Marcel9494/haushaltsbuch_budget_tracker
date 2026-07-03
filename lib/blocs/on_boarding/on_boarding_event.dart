import '../../data/models/account.dart';
import '../../data/models/category.dart';
import '../../data/models/dashboard_element.dart';

abstract class OnboardingEvent {}

class RunOnboarding extends OnboardingEvent {
  List<Category> startCategories;
  List<Account> startAccounts;
  List<DashboardElement> startDashboardElements;
  String userId;

  RunOnboarding({
    required this.startCategories,
    required this.startAccounts,
    required this.startDashboardElements,
    required this.userId,
  });
}
