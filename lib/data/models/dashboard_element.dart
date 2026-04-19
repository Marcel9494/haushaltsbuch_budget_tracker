import '../enums/dashboard_element_type.dart';
import '../repositories/account_repository.dart';
import '../repositories/booking_repository.dart';
import 'account.dart';
import 'booking.dart';

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

  factory DashboardElement.fromUserElementsMap(Map<String, dynamic> map) {
    final element = map['dashboard_elements'];

    return DashboardElement(
      id: element['id'],
      title: element['title'],
      showValue: element['show_value'],
      shortDescription: element['short_description'],
      icon: element['icon'],
      dashboardElementType: DashboardElementType.fromString(element['dashboard_element_type']),
      isSelected: element['default_is_selected'],
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

  static double calculateDisplayValue(DashboardElement dashboardElement, List<Booking> bookings, List<Account> accounts) {
    final BookingRepository bookingRepository = BookingRepository();
    final AccountRepository accountRepository = AccountRepository();
    if (dashboardElement.title == 'expenses' &&
        (dashboardElement.shortDescription == 'this_year' || dashboardElement.shortDescription == 'this_month')) {
      return bookingRepository.calculateExpenses(bookings);
    } else if (dashboardElement.title == 'revenue' &&
        (dashboardElement.shortDescription == 'this_year' || dashboardElement.shortDescription == 'this_month')) {
      return bookingRepository.calculateRevenue(bookings);
    } else if (dashboardElement.title == 'total_assets') {
      return accountRepository.calculateAssets(accounts);
    } else if (dashboardElement.title == 'total_debts') {
      return accountRepository.calculateDebts(accounts);
    } else if (dashboardElement.title == 'net_assets') {
      double assets = accountRepository.calculateAssets(accounts);
      double debts = accountRepository.calculateDebts(accounts);
      return assets - debts;
    } else {
      return 0.0;
    }
  }
}
