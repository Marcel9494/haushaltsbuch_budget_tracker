import '../enums/dashboard_element_type.dart';

class DashboardElement {
  final String? id;
  final String title;
  final double showValue;
  final String shortDescription;
  final String icon;
  final DashboardElementType dashboardElementType;
  bool isSelected;

  DashboardElement({
    this.id,
    required this.title,
    required this.showValue,
    required this.shortDescription,
    required this.icon,
    required this.dashboardElementType,
    required this.isSelected,
  });

  factory DashboardElement.fromMap(Map<String, dynamic> map) {
    return DashboardElement(
      id: map['id'],
      title: map['title'],
      showValue: map['show_value'],
      shortDescription: map['short_description'],
      icon: map['icon'],
      dashboardElementType: DashboardElementType.fromString(map['dashboard_element_type']),
      isSelected: map['default_is_selected'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'show_value': showValue,
      'short_description': shortDescription,
      'icon': icon,
      'dashboard_element_type': dashboardElementType.name,
      'default_is_selected': isSelected,
    };
  }
}
