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
