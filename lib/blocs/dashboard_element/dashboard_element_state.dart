import '../../data/models/dashboard_element.dart';

abstract class DashboardElementState {}

class DashboardElementInitial extends DashboardElementState {}

class DashboardElementCreated extends DashboardElementState {
  final DashboardElement dashboardElement;
  DashboardElementCreated(this.dashboardElement);
}

class DashboardElementsCreated extends DashboardElementState {
  DashboardElementsCreated();
}

class DashboardElementLoading extends DashboardElementState {}

class DashboardElementsLoaded extends DashboardElementState {
  final List<DashboardElement> dashboardElements;
  DashboardElementsLoaded(this.dashboardElements);
}

class DashboardElementError extends DashboardElementState {
  final String message;
  DashboardElementError(this.message);
}
