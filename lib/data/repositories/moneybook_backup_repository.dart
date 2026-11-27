import 'package:sqflite/sqflite.dart';

import '../models/moneybook_backup.dart';

// Liest eine Moneybook-Sicherung (SQLite-Datei, z.B. Moneybook_Backup.db) vom Gerät.
// Die Datei wird nur lesend geöffnet und nicht verändert.
class MoneybookBackupRepository {
  static const String invalidBackupError = 'invalid_moneybook_backup';

  static const List<String> _requiredTables = ['accounts', 'categories', 'bookings'];
  static const List<String> _requiredBookingColumns = ['type', 'title', 'date', 'amount', 'fromAccount', 'categorie'];

  Future<MoneybookBackup> loadBackup(String filePath) async {
    Database? database;
    try {
      database = await openDatabase(filePath, readOnly: true, singleInstance: false);

      final List<Map<String, Object?>> tableRows = await database.rawQuery("SELECT name FROM sqlite_master WHERE type = 'table'");
      final Set<String> tableNames = tableRows.map((row) => row['name']).whereType<String>().toSet();
      if (!_requiredTables.every(tableNames.contains)) {
        throw Exception(invalidBackupError);
      }

      final List<Map<String, Object?>> bookingColumnRows = await database.rawQuery('PRAGMA table_info(bookings)');
      final Set<String> bookingColumns = bookingColumnRows.map((row) => row['name']).whereType<String>().toSet();
      if (!_requiredBookingColumns.every(bookingColumns.contains)) {
        throw Exception(invalidBackupError);
      }

      // Budgets und Ziele gibt es erst in neueren Moneybook-Versionen.
      return MoneybookBackup.fromRows(
        accountRows: await database.query('accounts'),
        categoryRows: await database.query('categories'),
        bookingRows: await database.query('bookings', orderBy: 'date, id'),
        budgetRows: tableNames.contains('budgets') ? await database.query('budgets', orderBy: 'date, id') : const [],
        goalRows: tableNames.contains('goals') ? await database.query('goals') : const [],
      );
    } on DatabaseException {
      // z.B. "file is not a database", wenn eine andere Datei ausgewählt wurde.
      throw Exception(invalidBackupError);
    } finally {
      await database?.close();
    }
  }
}
