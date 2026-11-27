import '../../core/utils/moneybook_import_mapper.dart';
import '../enums/category_type.dart';

// Bereits vorhandene Daten des Benutzers, damit der Import keine Duplikate anlegt.
// Die Schlüssel sind normalisierte Namen (siehe normalizeImportName / importCategoryKey).
class ExistingImportData {
  final Map<String, String> accountIdsByName;
  final Map<String, String> categoryIdsByKey;
  final Map<String, String> activeGoalIdsByName;
  // Kategorien, für die der Benutzer bereits ein Budget hat.
  final Set<String> budgetCategoryIds;

  const ExistingImportData({
    this.accountIdsByName = const {},
    this.categoryIdsByKey = const {},
    this.activeGoalIdsByName = const {},
    this.budgetCategoryIds = const {},
  });

  factory ExistingImportData.fromRows({
    required List<Map<String, dynamic>> accountRows,
    required List<Map<String, dynamic>> categoryRows,
    required List<Map<String, dynamic>> activeGoalRows,
    required List<Map<String, dynamic>> budgetRows,
  }) {
    return ExistingImportData(
      accountIdsByName: {
        for (final row in accountRows) normalizeImportName(row['name'] as String): row['id'] as String,
      },
      categoryIdsByKey: {
        for (final row in categoryRows)
          importCategoryKey(row['category_name'] as String, CategoryType.fromString(row['category_type'] as String)): row['id'] as String,
      },
      activeGoalIdsByName: {
        for (final row in activeGoalRows) normalizeImportName(row['goal_name'] as String): row['id'] as String,
      },
      budgetCategoryIds: {
        for (final row in budgetRows) row['category_id'] as String,
      },
    );
  }
}
