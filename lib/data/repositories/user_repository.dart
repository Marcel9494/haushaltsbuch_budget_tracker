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

  Future<bool> existsUser(String userId) async {
    final userResponse = await Supabase.instance.client.from('users').select('id').eq('id', userId).maybeSingle();
    if (userResponse == null) {
      return false;
    }
    return true;
  }

  Future<void> updateUserLocale(String userId, Locale locale) async {
    await Supabase.instance.client.from('users').update({'locale': locale.toString()}).eq('id', userId);
  }

  Future<void> updateUserCurrency(String userId, String currencyCode) async {
    await Supabase.instance.client.from('users').update({'currency_code': currencyCode}).eq('id', userId);
  }

  Future<void> updateUserTimezone(String userId, String timezone) async {
    await Supabase.instance.client.from('users').update({'timezone': timezone}).eq('id', userId);
  }

  Future<void> updateUserHasOnboardingCompleted(String userId, bool hasOnboardingCompleted) async {
    await Supabase.instance.client.from('users').update({'has_onboarding_completed': hasOnboardingCompleted}).eq('id', userId);
  }

  Future<void> deleteUserAccount() async {
    try {
      await Supabase.instance.client.functions.invoke('delete-user-account');
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }
}
