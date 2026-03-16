import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../models/user.dart';

class UserRepository {
  Future<User> createUser(User newUser) async {
    final createdUser = await Supabase.instance.client.from('users').insert(newUser.toMap()).select().single();
    return User.fromMap(createdUser);
  }
}
