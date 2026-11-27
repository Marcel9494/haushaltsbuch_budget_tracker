import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/date_helper.dart';
import '../enums/goal_state_type.dart';
import '../helper_models/existing_import_data.dart';
import '../helper_models/moneybook_import_plan.dart';

// Speichert die aus einer Moneybook-Sicherung umgewandelten Daten in Supabase.
class MoneybookImportRepository {
  // Supabase liefert pro Anfrage höchstens 1000 Zeilen.
  static const int _pageSize = 1000;
  static const int _insertChunkSize = 500;
  // Ids werden beim Löschen in der URL übertragen, daher kleinere Pakete.
  static const int _deleteChunkSize = 100;

  Future<ExistingImportData> loadExistingData() async {
    final SupabaseClient supabase = Supabase.instance.client;
    final String userId = supabase.auth.currentUser!.id;

    return ExistingImportData.fromRows(
      accountRows: await _loadAllRows(supabase, 'accounts', 'id, name', userId),
      categoryRows: await _loadAllRows(supabase, 'categories', 'id, category_name, category_type', userId),
      activeGoalRows: await _loadAllRows(supabase, 'goals', 'id, goal_name', userId, activeGoalsOnly: true),
      budgetRows: await _loadAllRows(supabase, 'budgets', 'category_id', userId),
    );
  }

  // Speichert alle Datensätze des Plans. Schlägt ein Schritt fehl, werden die bereits
  // gespeicherten Datensätze wieder gelöscht, damit kein halber Import zurückbleibt.
  Future<void> importPlan(MoneybookImportPlan plan) async {
    final SupabaseClient supabase = Supabase.instance.client;
    final String userId = supabase.auth.currentUser!.id;
    final Map<String, List<String>> insertedIds = {};

    // Reihenfolge wegen der Fremdschlüssel: erst Konten, Kategorien und Ziele, dann Budgets und Buchungen.
    try {
      await _insertRows(
        supabase,
        'accounts',
        plan.newAccounts.map((account) => {...account.toMap(), 'id': account.id, 'user_id': userId}).toList(),
        insertedIds,
      );
      await _insertRows(
        supabase,
        'categories',
        plan.newCategories.map((category) => {...category.toMap(), 'id': category.id, 'user_id': userId}).toList(),
        insertedIds,
      );
      await _insertRows(
        supabase,
        'goals',
        plan.newGoals
            .map((goal) => {
                  ...goal.toMap(),
                  'id': goal.id,
                  'user_id': userId,
                  'start_date': toDateOnlyString(goal.startDate),
                  'end_date': toDateOnlyString(goal.endDate),
                })
            .toList(),
        insertedIds,
      );
      await _insertRows(
        supabase,
        'budgets',
        plan.budgets
            .map((budget) => {
                  ...budget.toMap(),
                  'id': budget.id,
                  'user_id': userId,
                  'budget_date': toDateOnlyString(budget.budgetDate!),
                })
            .toList(),
        insertedIds,
      );
      await _insertRows(
        supabase,
        'bookings',
        plan.bookings.map((booking) => {...booking.toMap(), 'id': booking.id, 'user_id': userId}).toList(),
        insertedIds,
      );
    } catch (e) {
      await _deleteInsertedRows(supabase, userId, insertedIds);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> _loadAllRows(
    SupabaseClient supabase,
    String table,
    String columns,
    String userId, {
    bool activeGoalsOnly = false,
  }) async {
    final List<Map<String, dynamic>> rows = [];
    int from = 0;
    while (true) {
      var query = supabase.from(table).select(columns).eq('user_id', userId);
      if (activeGoalsOnly) {
        query = query.eq('goal_state', GoalStateType.active.name);
      }
      final List<Map<String, dynamic>> page = await query.order('id').range(from, from + _pageSize - 1);
      rows.addAll(page);
      if (page.length < _pageSize) {
        return rows;
      }
      from += _pageSize;
    }
  }

  Future<void> _insertRows(
    SupabaseClient supabase,
    String table,
    List<Map<String, dynamic>> rows,
    Map<String, List<String>> insertedIds,
  ) async {
    for (int start = 0; start < rows.length; start += _insertChunkSize) {
      final int end = start + _insertChunkSize < rows.length ? start + _insertChunkSize : rows.length;
      final List<Map<String, dynamic>> chunk = rows.sublist(start, end);
      await supabase.from(table).insert(chunk);
      insertedIds.putIfAbsent(table, () => []).addAll(chunk.map((row) => row['id'] as String));
    }
  }

  // Löscht in umgekehrter Reihenfolge, damit keine Fremdschlüssel verletzt werden.
  Future<void> _deleteInsertedRows(SupabaseClient supabase, String userId, Map<String, List<String>> insertedIds) async {
    for (final String table in const ['bookings', 'budgets', 'goals', 'categories', 'accounts']) {
      final List<String> ids = insertedIds[table] ?? const [];
      for (int start = 0; start < ids.length; start += _deleteChunkSize) {
        final int end = start + _deleteChunkSize < ids.length ? start + _deleteChunkSize : ids.length;
        try {
          await supabase.from(table).delete().inFilter('id', ids.sublist(start, end)).eq('user_id', userId);
        } catch (_) {
          // Aufräumen ist nur ein Versuch, der ursprüngliche Fehler wird trotzdem weitergegeben.
        }
      }
    }
  }
}
