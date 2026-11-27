abstract class MoneybookImportEvent {
  const MoneybookImportEvent();
}

// Der Benutzer hat eine Sicherungsdatei ausgewählt. Sie wird gelesen und als Vorschau aufbereitet.
class MoneybookBackupSelected extends MoneybookImportEvent {
  final String filePath;

  const MoneybookBackupSelected({
    required this.filePath,
  });
}

// Der Benutzer hat die Vorschau bestätigt und startet den Import.
class MoneybookImportConfirmed extends MoneybookImportEvent {
  const MoneybookImportConfirmed();
}

// Zurück zum Anfang, z.B. um eine andere Datei auszuwählen.
class MoneybookImportReset extends MoneybookImportEvent {
  const MoneybookImportReset();
}
