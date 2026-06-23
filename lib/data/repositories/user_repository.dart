import 'dart:ui';

import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../models/user.dart';

class UserRepository {
  Future<User> createUser(User newUser) async {
    final createdUser = await Supabase.instance.client.from('users').insert(newUser.toMap()).select().single();
    return User.fromMap(createdUser);
  }

  Future<User> loadUser(String userId) async {
    final userData = await Supabase.instance.client.from('users').select().eq('id', userId).single();
    return User.fromMap(userData);
  }

  Future<void> updateUserLocale(String userId, Locale locale) async {
    await Supabase.instance.client.from('users').update({'locale': locale.toString()}).eq('id', userId);
  }

  Future<void> updateUserCurrency(String userId, String currency) async {
    await Supabase.instance.client.from('users').update({'currency': currency}).eq('id', userId);
  }

  Future<void> updateUserHasOnboardingCompleted(String userId, bool hasOnboardingCompleted) async {
    await Supabase.instance.client.from('users').update({'has_onboarding_completed': hasOnboardingCompleted}).eq('id', userId);
  }
}
