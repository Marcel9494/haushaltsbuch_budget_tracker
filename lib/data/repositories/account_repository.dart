import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/account.dart';

class AccountRepository {
  Future<Account> createAccount(Account newAccount) async {
    final createdAccount = await Supabase.instance.client.from('accounts').insert(newAccount.toMap()).select().single();
    return Account.fromMap(createdAccount);
  }

  Future<List<Account>> loadAccounts() async {
    final accounts = await Supabase.instance.client.from('accounts').select().order('account_type', ascending: false);
    return (accounts as List).map((data) => Account.fromMap(data)).toList();
  }
}
