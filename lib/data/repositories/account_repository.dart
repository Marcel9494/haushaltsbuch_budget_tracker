import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/bookings/data/enums/booking_type.dart';
import '../enums/account_type.dart';
import '../models/account.dart';
import '../models/booking.dart';

class AccountRepository {
  Future<Account> createAccount(Account newAccount) async {
    try {
      final createdAccount = await Supabase.instance.client.from('accounts').insert(newAccount.toMap()).select().single();
      return Account.fromMap(createdAccount);
    } on PostgrestException catch (e) {
      // Postgresql Fehlercode für unique_violation
      if (e.code == '23505') {
        throw Exception('duplicated_account');
      }
      rethrow;
    }
  }

  Future<void> createAccounts(List<Account> newAccounts) async {
    try {
      final accountMap = <Map<String, dynamic>>[];

      for (int i = 0; i < newAccounts.length; i++) {
        accountMap.add({
          'name': newAccounts[i].name,
          'account_type': newAccounts[i].accountType.name,
          'balance': newAccounts[i].balance,
        });
      }
      await Supabase.instance.client.from('accounts').insert(accountMap);
    } on PostgrestException catch (e) {
      // Postgresql Fehlercode für unique_violation
      if (e.code == '23505') {
        throw Exception('duplicated_account');
      }
      rethrow;
    }
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

  Future<void> updateAccountBalance(List<Booking> bookings) async {
    double totalSum = 0.0;
    final SupabaseClient supabase = Supabase.instance.client;
    if (bookings.isEmpty) {
      return;
    }
    for (int i = 0; i < bookings.length; i++) {
      // Wenn die Buchung in der Zukunft liegt, dann mit nächster Buchung weitermachen
      if (bookings[i].bookingDate.isAfter(DateTime.now()) || bookings[i].bookingDate.isAtSameMomentAs(DateTime.now())) {
        continue;
      }
      totalSum += bookings[i].amount;
    }
    if (bookings[0].bookingType == BookingType.expense) {
      final debitAccount = await supabase.from('accounts').select('balance').eq('id', bookings[0].debitAccountId!).single();
      await supabase
          .from('accounts')
          .update({'balance': debitAccount['balance'] - totalSum})
          .eq('id', bookings[0].debitAccountId!)
          .eq('user_id', supabase.auth.currentUser!.id);
    } else if (bookings[0].bookingType == BookingType.income) {
      final debitAccount = await supabase.from('accounts').select('balance').eq('id', bookings[0].debitAccountId!).single();
      await supabase
          .from('accounts')
          .update({'balance': debitAccount['balance'] + totalSum})
          .eq('id', bookings[0].debitAccountId!)
          .eq('user_id', supabase.auth.currentUser!.id);
    } else if (bookings[0].bookingType == BookingType.transfer) {
      final debitAccount = await supabase.from('accounts').select('balance').eq('id', bookings[0].debitAccountId!).single();
      final targetAccount = await supabase.from('accounts').select('balance').eq('id', bookings[0].targetAccountId!).single();
      await supabase
          .from('accounts')
          .update({'balance': debitAccount['balance'] - totalSum})
          .eq('id', bookings[0].debitAccountId!)
          .eq('user_id', supabase.auth.currentUser!.id);
      await supabase
          .from('accounts')
          .update({'balance': targetAccount['balance'] + totalSum})
          .eq('id', bookings[0].targetAccountId!)
          .eq('user_id', supabase.auth.currentUser!.id);
    }
  }

  Future<void> reverseAccountBalance(Booking oldBooking) async {
    final SupabaseClient supabase = Supabase.instance.client;
    if (oldBooking.bookingDate.isAfter(DateTime.now()) || oldBooking.bookingDate.isAtSameMomentAs(DateTime.now())) {
      return;
    }

    if (oldBooking.bookingType == BookingType.expense) {
      final debitAccount = await supabase.from('accounts').select('balance').eq('id', oldBooking.debitAccountId!).single();
      await supabase
          .from('accounts')
          .update({'balance': debitAccount['balance'] + oldBooking.amount})
          .eq('id', oldBooking.debitAccountId!)
          .eq('user_id', supabase.auth.currentUser!.id);
    } else if (oldBooking.bookingType == BookingType.income) {
      final debitAccount = await supabase.from('accounts').select('balance').eq('id', oldBooking.debitAccountId!).single();
      await supabase
          .from('accounts')
          .update({'balance': debitAccount['balance'] - oldBooking.amount})
          .eq('id', oldBooking.debitAccountId!)
          .eq('user_id', supabase.auth.currentUser!.id);
    } else if (oldBooking.bookingType == BookingType.transfer) {
      final debitAccount = await supabase.from('accounts').select('balance').eq('id', oldBooking.debitAccountId!).single();
      final targetAccount = await supabase.from('accounts').select('balance').eq('id', oldBooking.targetAccountId!).single();
      await supabase
          .from('accounts')
          .update({'balance': debitAccount['balance'] + oldBooking.amount})
          .eq('id', oldBooking.debitAccountId!)
          .eq('user_id', supabase.auth.currentUser!.id);
      await supabase
          .from('accounts')
          .update({'balance': targetAccount['balance'] - oldBooking.amount})
          .eq('id', oldBooking.targetAccountId!)
          .eq('user_id', supabase.auth.currentUser!.id);
    }
  }

  Future<void> reverseAccountBalances(List<Booking> bookings) async {
    final SupabaseClient supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser!.id;

    final Map<String, double> balanceChanges = {};

    for (final booking in bookings) {
      if (booking.bookingDate.isAfter(DateTime.now()) || booking.bookingDate.isAtSameMomentAs(DateTime.now())) {
        continue;
      }

      switch (booking.bookingType) {
        case BookingType.expense:
          balanceChanges.update(
            booking.debitAccountId!,
            (value) => value + booking.amount,
            ifAbsent: () => booking.amount,
          );
          break;

        case BookingType.income:
          balanceChanges.update(
            booking.debitAccountId!,
            (value) => value - booking.amount,
            ifAbsent: () => -booking.amount,
          );
          break;

        case BookingType.transfer:
          balanceChanges.update(
            booking.debitAccountId!,
            (value) => value + booking.amount,
            ifAbsent: () => booking.amount,
          );

          balanceChanges.update(
            booking.targetAccountId!,
            (value) => value - booking.amount,
            ifAbsent: () => -booking.amount,
          );
          break;
      }
    }

    final accountIds = balanceChanges.keys.toList();

    final accounts = await supabase.from('accounts').select('id, balance').inFilter('id', accountIds).eq('user_id', userId);

    // Updates auf betroffenen Accounts durchführen
    for (final account in accounts) {
      final id = account['id'];
      final currentBalance = account['balance'];
      final change = balanceChanges[id]!;

      await supabase.from('accounts').update({'balance': currentBalance + change}).eq('id', id).eq('user_id', userId);
    }
  }
}
