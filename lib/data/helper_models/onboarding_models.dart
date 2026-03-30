import 'package:haushaltsbuch_budget_tracker/data/helper_models/start_account.dart';
import 'package:haushaltsbuch_budget_tracker/data/helper_models/start_category.dart';

import '../../features/categories/data/enums/category_type.dart';
import '../enums/account_type.dart';
import '../models/dashboard_element.dart';

// Start Ausgabekategorien
final List<StartCategory> expensesStartCategories = [
  StartCategory(categoryName: 'Lebensmittel', categoryType: CategoryType.expense, isSelected: true),
  StartCategory(categoryName: 'Haushaltswaren', categoryType: CategoryType.expense, isSelected: true),
  StartCategory(categoryName: 'Wohnen / Miete', categoryType: CategoryType.expense, isSelected: true),
  StartCategory(categoryName: 'Nebenkosten', categoryType: CategoryType.expense, isSelected: true),
  StartCategory(categoryName: 'Bildung', categoryType: CategoryType.expense, isSelected: true),
  StartCategory(categoryName: 'Kleidung / Mode', categoryType: CategoryType.expense, isSelected: true),
  StartCategory(categoryName: 'Sport / Fitness', categoryType: CategoryType.expense, isSelected: true),
  StartCategory(categoryName: 'Freizeit', categoryType: CategoryType.expense, isSelected: true),
  StartCategory(categoryName: 'Geschenke', categoryType: CategoryType.expense, isSelected: true),
  StartCategory(categoryName: 'Spende', categoryType: CategoryType.expense, isSelected: true),
  StartCategory(categoryName: 'Restaurant', categoryType: CategoryType.expense, isSelected: true),
  StartCategory(categoryName: 'Mobilität', categoryType: CategoryType.expense, isSelected: true),
  StartCategory(categoryName: 'Abo / Vertrag', categoryType: CategoryType.expense, isSelected: true),
  StartCategory(categoryName: 'Technik', categoryType: CategoryType.expense, isSelected: true),
  StartCategory(categoryName: 'Urlaub / Reisen', categoryType: CategoryType.expense, isSelected: true),
  StartCategory(categoryName: 'Schönheitspflege', categoryType: CategoryType.expense, isSelected: true),
  StartCategory(categoryName: 'Kredit', categoryType: CategoryType.expense, isSelected: true),
  StartCategory(categoryName: 'Sonstiges', categoryType: CategoryType.expense, isSelected: true),
  StartCategory(categoryName: 'Bar / Kneipe', categoryType: CategoryType.expense, isSelected: false),
  StartCategory(categoryName: 'Haustiere', categoryType: CategoryType.expense, isSelected: false),
  StartCategory(categoryName: 'Möbel', categoryType: CategoryType.expense, isSelected: false),
];

// Start Einnahmekategorien
final List<StartCategory> revenueStartCategories = [
  StartCategory(categoryName: 'Gehalt', categoryType: CategoryType.income, isSelected: true),
  StartCategory(categoryName: 'Zinsen', categoryType: CategoryType.income, isSelected: true),
  StartCategory(categoryName: 'Weihnachtsgeld', categoryType: CategoryType.income, isSelected: true),
  StartCategory(categoryName: 'Urlaubsgeld', categoryType: CategoryType.income, isSelected: true),
  StartCategory(categoryName: 'Sonstiges', categoryType: CategoryType.income, isSelected: true),
  StartCategory(categoryName: 'Bonus', categoryType: CategoryType.income, isSelected: false),
  StartCategory(categoryName: 'Dividenden', categoryType: CategoryType.income, isSelected: false),
  StartCategory(categoryName: 'Mieteinnahmen', categoryType: CategoryType.income, isSelected: false),
  StartCategory(categoryName: 'Nebeneinkünfte', categoryType: CategoryType.income, isSelected: false),
  StartCategory(categoryName: 'Gewinnprämie', categoryType: CategoryType.income, isSelected: false),
  StartCategory(categoryName: 'Steuerrückerstattung', categoryType: CategoryType.income, isSelected: false),
];

// Startkonten
final List<StartAccount> allStartAccounts = [
  StartAccount(accountName: 'Girokonto', accountType: AccountType.account, balance: 0.0, isSelected: true),
  StartAccount(accountName: 'Sparbuch', accountType: AccountType.account, balance: 0.0, isSelected: true),
  StartAccount(accountName: 'Bausparvertrag', accountType: AccountType.account, balance: 0.0, isSelected: false),
  StartAccount(accountName: 'Aktiendepot', accountType: AccountType.capitalInvestment, balance: 0.0, isSelected: true),
  StartAccount(accountName: 'Geldbeutel', accountType: AccountType.cash, balance: 0.0, isSelected: true),
  StartAccount(accountName: 'Visa Kreditkarte', accountType: AccountType.card, balance: 0.0, isSelected: false),
  StartAccount(accountName: 'Mastercard Kreditkarte', accountType: AccountType.card, balance: 0.0, isSelected: false),
  StartAccount(accountName: 'Versicherungskonto', accountType: AccountType.insurance, balance: 0.0, isSelected: false),
  StartAccount(accountName: 'Kredit', accountType: AccountType.credit, balance: 0.0, isSelected: false),
  StartAccount(accountName: 'Sonstiges', accountType: AccountType.other, balance: 0.0, isSelected: true),
];

// Start Dashboard Elemente
List<DashboardElement> selectedStartDashboardElements = [];
