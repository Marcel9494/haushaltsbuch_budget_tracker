import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../enums/account_type.dart';
import '../enums/booking_type.dart';
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

  Future<List<Account>> loadAccounts({List<String> filteredAccountIds = const []}) async {
    var query = Supabase.instance.client.from('accounts').select();
    if (filteredAccountIds.isNotEmpty) {
      query = query.not('id', 'in', filteredAccountIds); // filtert die übergebenen Ids heraus, wichtig bei z.B. Kontotransfer bei Kontolöschung.
    }
    final accounts = await query.order('account_type', ascending: true).order('balance', ascending: false);
    return (accounts as List).map((data) => Account.fromMap(data)).toList();
  }

  Future<void> updateAccountBalancesWithExchangeRate(String userId, double exchangeRate) async {
    final supabase = Supabase.instance.client;
    final accounts = await supabase.from('accounts').select('id, balance').eq('user_id', userId);
    for (final account in accounts) {
      final balance = (account['balance'] as num?)?.toDouble() ?? 0;
      await supabase.from('accounts').update({'balance': balance * exchangeRate}).eq('id', account['id']).eq('user_id', userId);
    }
  }

  double calculateAssets(List<Account> accounts) {
    double totalAssets = 0.0;
    for (Account account in accounts) {
      if (account.balance >= 0 && account.accountType != AccountType.credit) {
        totalAssets += account.balance;
      }
    }
    return totalAssets;
  }

  double calculateDebts(List<Account> accounts) {
    double totalDebts = 0.0;
    for (Account account in accounts) {
      if (account.balance < 0 || account.accountType == AccountType.credit) {
        totalDebts += account.balance;
      }
    }
    return totalDebts;
  }

  Map<String, double> calculateAccountTypeBalances(List<Account> accounts) {
    Map<String, double> accountTypeBalances = {};

    for (Account account in accounts) {
      String type = account.accountType.name;
      double balance = account.balance;
      accountTypeBalances[type] = (accountTypeBalances[type] ?? 0.0) + balance;
    }

    return accountTypeBalances;
  }

  Future<void> updateAccountBalance(List<Booking> bookings, BuildContext context) async {
    if (bookings.isEmpty) {
      return;
    }

    final SupabaseClient supabase = Supabase.instance.client;
    final String userId = supabase.auth.currentUser!.id;

    double totalSum = 0.0;

    // Nur Buchungen berücksichtigen, die bereits gebucht wurden.
    for (final booking in bookings) {
      if (!booking.bookingDate.isBefore(DateTime.now())) {
        continue;
      }
      totalSum += booking.amount;
    }

    if (totalSum == 0.0) {
      return;
    }

    final Booking firstBooking = bookings.first;

    final String? debitAccountId = firstBooking.debitAccountId;
    final String? targetAccountId = firstBooking.targetAccountId;

    if (firstBooking.bookingType == BookingType.expense) {
      if (debitAccountId == null) {
        return;
      }

      final debitAccount = await supabase.from('accounts').select('balance').eq('id', debitAccountId).eq('user_id', userId).single();
      final double currentBalance = (debitAccount['balance'] as num).toDouble();
      await supabase.from('accounts').update({'balance': currentBalance - totalSum}).eq('id', debitAccountId).eq('user_id', userId);
      return;
    }

    if (firstBooking.bookingType == BookingType.income) {
      if (debitAccountId == null) {
        return;
      }

      final debitAccount = await supabase.from('accounts').select('balance').eq('id', debitAccountId).eq('user_id', userId).single();
      final double currentBalance = (debitAccount['balance'] as num).toDouble();
      await supabase.from('accounts').update({'balance': currentBalance + totalSum}).eq('id', debitAccountId).eq('user_id', userId);

      return;
    }

    if (firstBooking.bookingType == BookingType.transfer) {
      if (debitAccountId == null || targetAccountId == null) {
        return;
      }

      final accounts = await supabase.from('accounts').select('id, balance').eq('user_id', userId).inFilter(
        'id',
        [debitAccountId, targetAccountId],
      );

      if (accounts.length != 2) {
        return;
      }

      final debitAccount = accounts.firstWhere((account) => account['id'] == debitAccountId);
      final targetAccount = accounts.firstWhere((account) => account['id'] == targetAccountId);

      final double debitBalance = (debitAccount['balance'] as num).toDouble();
      final double targetBalance = (targetAccount['balance'] as num).toDouble();

      await supabase.from('accounts').update({'balance': debitBalance - totalSum}).eq('id', debitAccountId).eq('user_id', userId);
      await supabase.from('accounts').update({'balance': targetBalance + totalSum}).eq('id', targetAccountId).eq('user_id', userId);
    }
  }

  Future<void> reverseAccountBalance(Booking oldBooking, BuildContext context) async {
    final SupabaseClient supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      return;
    }

    if (!oldBooking.bookingDate.isBefore(DateTime.now())) {
      return;
    }

    // Ausgabe / Einnahme
    if (oldBooking.bookingType == BookingType.expense || oldBooking.bookingType == BookingType.income) {
      final debitAccountId = oldBooking.debitAccountId;

      // Kein Konto ausgewählt -> nichts rückgängig zu machen.
      if (debitAccountId == null) {
        return;
      }

      final debitAccount = await supabase.from('accounts').select('balance').eq('id', debitAccountId).eq('user_id', userId).maybeSingle();

      // Konto wurde zwischenzeitlich gelöscht -> nichts verändern.
      if (debitAccount == null) {
        return;
      }

      final currentBalance = (debitAccount['balance'] as num).toDouble();
      double newBalance;

      // Buchun rückgängig machen
      if (oldBooking.bookingType == BookingType.expense) {
        newBalance = currentBalance + oldBooking.amount;
      } else {
        newBalance = currentBalance - oldBooking.amount;
      }
      await supabase.from('accounts').update({'balance': newBalance}).eq('id', debitAccountId).eq('user_id', userId);
      return;
    }

    // Übertragsbuchung
    if (oldBooking.bookingType == BookingType.transfer) {
      final debitAccountId = oldBooking.debitAccountId;
      final targetAccountId = oldBooking.targetAccountId;
      // Wenn eines der beiden Konten fehlt, kann der Transfer
      // nicht vollständig rückgängig gemacht werden.
      if (debitAccountId == null || targetAccountId == null) {
        return;
      }

      final debitAccount = await supabase.from('accounts').select('balance').eq('id', debitAccountId).eq('user_id', userId).maybeSingle();
      final targetAccount = await supabase.from('accounts').select('balance').eq('id', targetAccountId).eq('user_id', userId).maybeSingle();

      // Eines der Konten wurde gelöscht -> nichts verändern.
      if (debitAccount == null || targetAccount == null) {
        return;
      }

      final debitBalance = (debitAccount['balance'] as num).toDouble();
      final targetBalance = (targetAccount['balance'] as num).toDouble();

      await supabase.from('accounts').update({'balance': debitBalance + oldBooking.amount}).eq('id', debitAccountId).eq('user_id', userId);
      await supabase.from('accounts').update({'balance': targetBalance - oldBooking.amount}).eq('id', targetAccountId).eq('user_id', userId);
    }
  }

  Future<void> reverseAccountBalances(List<Booking> bookings) async {
    final SupabaseClient supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser!.id;

    final Map<String, double> balanceChanges = {};

    for (final booking in bookings) {
      if (!booking.bookingDate.isBefore(DateTime.now())) {
        continue;
      }

      switch (booking.bookingType) {
        case BookingType.expense:
          // Ausgabe:
          // ursprüngliche Buchung hat den Debit-Account belastet.
          // Beim Zurücksetzen muss der Betrag wieder gutgeschrieben werden.
          if (booking.debitAccountId != null) {
            balanceChanges.update(
              booking.debitAccountId!,
              (value) => value + booking.amount,
              ifAbsent: () => booking.amount,
            );
          }
          break;

        case BookingType.income:
          // Einnahme:
          // ursprüngliche Buchung hat den Debit-Account erhöht.
          // Beim Zurücksetzen muss der Betrag wieder abgezogen werden.
          if (booking.debitAccountId != null) {
            balanceChanges.update(
              booking.debitAccountId!,
              (value) => value - booking.amount,
              ifAbsent: () => -booking.amount,
            );
          }
          break;

        case BookingType.transfer:
          // Transfer:
          // Debit-Account wieder erhöhen
          if (booking.debitAccountId != null) {
            balanceChanges.update(
              booking.debitAccountId!,
              (value) => value + booking.amount,
              ifAbsent: () => booking.amount,
            );
          }

          // Target-Account wieder reduzieren
          if (booking.targetAccountId != null) {
            balanceChanges.update(
              booking.targetAccountId!,
              (value) => value - booking.amount,
              ifAbsent: () => -booking.amount,
            );
          }
          break;
      }
    }

    if (balanceChanges.isEmpty) {
      return;
    }

    final accountIds = balanceChanges.keys.toList();
    final accounts = await supabase.from('accounts').select('id, balance').inFilter('id', accountIds).eq('user_id', userId);

    // Updates auf betroffenen Accounts durchführen
    for (final account in accounts) {
      final String id = account['id'];
      final double currentBalance = (account['balance'] as num).toDouble();

      final double change = balanceChanges[id] ?? 0;

      await supabase.from('accounts').update({'balance': currentBalance + change}).eq('id', id).eq('user_id', userId);
    }
  }

  Future<Account?> getAccountByName(String userId, String name) async {
    final SupabaseClient supabase = Supabase.instance.client;
    final response = await supabase.from('accounts').select().eq('user_id', userId).eq('name', name).maybeSingle();

    if (response == null) {
      return null;
    }
    return Account.fromMap(response);
  }
}
