import 'package:haushaltsbuch_budget_tracker/data/repositories/budget_repository.dart';

import '../enums/dashboard_element_type.dart';
import '../repositories/account_repository.dart';
import '../repositories/booking_repository.dart';
import 'account.dart';
import 'booking.dart';
import 'budget.dart';

class DashboardElement {
  final String? id;
  final String title;
  final num showValue;
  final String shortDescription;
  final String icon;
  final DashboardElementType dashboardElementType;
  final Map<String, dynamic> elementConfig;
  int defaultOrder;
  int? position;
  bool isSelected;

  DashboardElement({
    this.id,
    required this.title,
    required this.showValue,
    required this.shortDescription,
    required this.icon,
    required this.dashboardElementType,
    required this.isSelected,
    this.defaultOrder = 0,
    this.position,
    this.elementConfig = const {},
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
      defaultOrder: map['default_order'],
      elementConfig: Map<String, dynamic>.from(map['element_config'] ?? {}),
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
      defaultOrder: element['default_order'],
      elementConfig: Map<String, dynamic>.from(element['element_config'] ?? {}),
      position: map['position'],
    );
  }

  factory DashboardElement.fromUsersDashboardElementsMap(Map<String, dynamic> map) {
    return DashboardElement(
      id: map['id'],
      title: map['title'],
      showValue: map['show_value'],
      shortDescription: map['short_description'],
      icon: map['icon'],
      dashboardElementType: DashboardElementType.fromString(
        map['dashboard_element_type'],
      ),
      isSelected: map['is_selected'] ?? false,
      defaultOrder: map['default_order'],
      elementConfig: Map<String, dynamic>.from(map['element_config'] ?? {}),
      position: map['position'],
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
      'default_order': defaultOrder,
      'element_config': elementConfig,
    };
  }

  static num calculateDisplayValue(DashboardElement dashboardElement, List<Booking> bookings, List<Account> accounts, List<Budget> budgets) {
    final BookingRepository bookingRepository = BookingRepository();
    final AccountRepository accountRepository = AccountRepository();
    final BudgetRepository budgetRepository = BudgetRepository();

    if (dashboardElement.title.trim() == 'expenses' &&
        (dashboardElement.shortDescription.trim() == 'this_year' || dashboardElement.shortDescription.trim() == 'this_month')) {
      return bookingRepository.calculateExpenses(bookings);
    } else if (dashboardElement.title.trim() == 'revenue' &&
        (dashboardElement.shortDescription.trim() == 'this_year' || dashboardElement.shortDescription.trim() == 'this_month')) {
      return bookingRepository.calculateRevenue(bookings);
    } else if (dashboardElement.title.trim() == 'balance' &&
        (dashboardElement.shortDescription.trim() == 'this_year' || dashboardElement.shortDescription.trim() == 'this_month')) {
      double revenue = bookingRepository.calculateRevenue(bookings);
      double expenses = bookingRepository.calculateExpenses(bookings);
      return revenue - expenses;
    } else if (dashboardElement.title.trim() == 'overall_remaining_budget' &&
        (dashboardElement.shortDescription.trim() == 'this_year' || dashboardElement.shortDescription.trim() == 'this_month')) {
      return budgetRepository.calculateOverallRemainingBudgetAmount(budgets, bookings);
    } else if (dashboardElement.title.trim() == 'number_of_revenue_bookings') {
      return bookingRepository.getNumberOfRevenueBookings(bookings);
    } else if (dashboardElement.title.trim() == 'number_of_expense_bookings') {
      return bookingRepository.getNumberOfExpenseBookings(bookings);
    } else if (dashboardElement.title.trim() == 'number_of_transfer_bookings') {
      return bookingRepository.getNumberOfTransferBookings(bookings);
    } else if (dashboardElement.title.trim() == 'total_assets') {
      return accountRepository.calculateAssets(accounts);
    } else if (dashboardElement.title.trim() == 'total_debts') {
      return accountRepository.calculateDebts(accounts).abs();
    } else if (dashboardElement.title.trim() == 'account_balance') {
      double assets = accountRepository.calculateAssets(accounts);
      double debts = accountRepository.calculateDebts(accounts);
      return assets - debts.abs();
    } else {
      return 0.0;
    }
  }
}
