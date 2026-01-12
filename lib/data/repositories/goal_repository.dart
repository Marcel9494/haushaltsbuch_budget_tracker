import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/goal.dart';

class GoalRepository {
  Future<Goal> createGoal(Goal newGoal) async {
    final createdGoal = await Supabase.instance.client.from('goals').insert(newGoal.toMap()).select().single();
    return Goal.fromMap(createdGoal);
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
