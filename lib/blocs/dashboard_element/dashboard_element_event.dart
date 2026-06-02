import '../../data/models/dashboard_element.dart';

abstract class DashboardElementEvent {}

class CreateDashboardElements extends DashboardElementEvent {
  final List<DashboardElement> dashboardElements;

  CreateDashboardElements({
    required this.dashboardElements,
  });
}

class UpdateUsersDashboardElements extends DashboardElementEvent {
  final List<DashboardElement> dashboardElements;

  UpdateUsersDashboardElements({
    required this.dashboardElements,
  });
}

class LoadDashboardElements extends DashboardElementEvent {
  LoadDashboardElements();
}

class LoadUserDashboardElements extends DashboardElementEvent {
  LoadUserDashboardElements();
}

class LoadDashboardElementsWithUserSelection extends DashboardElementEvent {
  LoadDashboardElementsWithUserSelection();
}
