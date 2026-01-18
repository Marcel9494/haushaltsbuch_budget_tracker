import 'package:supabase_flutter/supabase_flutter.dart';

import '../enums/account_type.dart';
import '../models/account.dart';

class AccountRepository {
  Future<Account> createAccount(Account newAccount) async {
    final createdAccount = await Supabase.instance.client.from('accounts').insert(newAccount.toMap()).select().single();
    return Account.fromMap(createdAccount);
  }

  Future<List<Account>> loadAccounts() async {
    final accounts = await Supabase.instance.client.from('accounts').select().order('account_type', ascending: true);
    return (accounts as List).map((data) => Account.fromMap(data)).toList();
  }

  Future<Account> updateAccount(Account account) async {
    try {
      final SupabaseClient supabase = Supabase.instance.client;
      final updatedAccount = await supabase
          .from('accounts')
          .update(account.toMap())
          .eq('id', account.id!)
          .eq('user_id', supabase.auth.currentUser!.id)
          .select()
          .single();
      return Account.fromMap(updatedAccount);
    } on PostgrestException catch (e) {
      // Postgresql Fehlercode für unique_violation
      if (e.code == '23505') {
        throw Exception('duplicated_account');
      }
      rethrow;
    }
  }

  Future<Account> deleteAccount(String accountId, [Account? transferAccount]) async {
    final SupabaseClient supabase = Supabase.instance.client;
    if (transferAccount != null) {
      final account = await supabase.from('accounts').select().eq('id', accountId).eq('user_id', supabase.auth.currentUser!.id).single();
      final balance = account['balance'];
      await supabase.from('accounts').update({'balance': balance + transferAccount.balance}).eq('id', transferAccount.id!);
    }

    final deletedAccount =
        await supabase.from('accounts').delete().eq('id', accountId).eq('user_id', supabase.auth.currentUser!.id).select().single();
    return Account.fromMap(deletedAccount);
  }

  double calculateAssets(List<Account> accounts) {
    double totalAssets = 0;
    for (Account account in accounts) {
      if (account.balance >= 0 && account.accountType != AccountType.credit) {
        totalAssets += account.balance;
      }
    }
    return totalAssets;
  }

  double calculateDebts(List<Account> accounts) {
    double totalDebts = 0;
    for (Account account in accounts) {
      if (account.balance < 0 || account.accountType == AccountType.credit) {
        totalDebts += account.balance;
      }
    }
    return totalDebts;
  }
}
