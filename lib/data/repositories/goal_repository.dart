import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/goal.dart';

class GoalRepository {
  Future<Goal> createGoal(Goal newGoal) async {
    final createdGoal = await Supabase.instance.client.from('goals').insert(newGoal.toMap()).select().single();
    return Goal.fromMap(createdGoal);
  }

  Future<Goal> updateGoal(Goal goal) async {
    try {
      final SupabaseClient supabase = Supabase.instance.client;
      final updatedGoal =
          await supabase.from('goals').update(goal.toMap()).eq('id', goal.id!).eq('user_id', supabase.auth.currentUser!.id).select().single();
      return Goal.fromMap(updatedGoal);
    } on PostgrestException catch (e) {
      // Postgresql Fehlercode für unique_violation
      if (e.code == '23505') {
        throw Exception('duplicated_goal');
      }
      rethrow;
    }
  }

  Future<Goal> deleteGoal(String goalId) async {
    final SupabaseClient supabase = Supabase.instance.client;
    final deletedGoal = await supabase.from('goals').delete().eq('id', goalId).eq('user_id', supabase.auth.currentUser!.id).select().single();
    return Goal.fromMap(deletedGoal);
  }

  Future<List<Goal>> loadGoals() async {
    final goals = await Supabase.instance.client.from('goals').select().order('goal_amount', ascending: true);
    for (int i = 0; i < goals.length; i++) {
      double totalGoalAmount = 0.0;
      final bookings = await Supabase.instance.client
          .from('bookings')
          .select('*, goals(*)')
          .eq('goals.user_id', Supabase.instance.client.auth.currentUser!.id)
          .eq('goal_id', goals[i]['id']);
      for (int j = 0; j < bookings.length; j++) {
        totalGoalAmount += bookings[j]['amount'];
      }
      goals[i]['current_amount'] = totalGoalAmount;
    }
    return (goals as List).map((data) => Goal.fromMap(data)).toList();
  }
}
