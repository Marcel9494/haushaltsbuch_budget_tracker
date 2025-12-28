import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/budget.dart';

class BudgetRepository {
  Future<Budget> createBudget(Budget newBudget) async {
    final createdBudget = await Supabase.instance.client.from('budgets').insert(newBudget.toMap()).select().single();
    return Budget.fromMap(createdBudget);
  }

  Future<List<Budget>> loadBudgets() async {
    final budgets = await Supabase.instance.client.from('budgets').select('*, categories(*)').order('budget_amount', ascending: false);
    return (budgets as List).map((data) => Budget.fromMap(data)).toList();
  }
}
