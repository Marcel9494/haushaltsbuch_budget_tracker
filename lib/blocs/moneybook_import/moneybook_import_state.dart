import '../../data/helper_models/moneybook_import_plan.dart';

abstract class MoneybookImportState {
  const MoneybookImportState();
}

class MoneybookImportInitial extends MoneybookImportState {
  const MoneybookImportInitial();
}

// Sicherungsdatei wird gelesen und mit den vorhandenen Daten abgeglichen.
class MoneybookImportLoading extends MoneybookImportState {
  const MoneybookImportLoading();
}

// Vorschau, was importiert wird. Der Benutzer muss den Import noch bestätigen.
class MoneybookImportPreview extends MoneybookImportState {
  final MoneybookImportPlan plan;

  const MoneybookImportPreview(this.plan);
}

class MoneybookImportInProgress extends MoneybookImportState {
  final MoneybookImportPlan plan;

  const MoneybookImportInProgress(this.plan);
}

class MoneybookImportSuccess extends MoneybookImportState {
  final MoneybookImportPlan plan;

  const MoneybookImportSuccess(this.plan);
}

// message ist ein Übersetzungsschlüssel.
class MoneybookImportFailure extends MoneybookImportState {
  final String message;

  const MoneybookImportFailure(this.message);
}
