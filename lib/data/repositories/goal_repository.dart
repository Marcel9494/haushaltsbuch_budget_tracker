import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/goal.dart';

class GoalRepository {
  Future<Goal> createGoal(Goal newGoal) async {
    final createdGoal = await Supabase.instance.client.from('goals').insert(newGoal.toMap()).select().single();
    return Goal.fromMap(createdGoal);
  }
}
