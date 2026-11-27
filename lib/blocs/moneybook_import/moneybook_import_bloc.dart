import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/moneybook_import_mapper.dart';
import '../../data/helper_models/existing_import_data.dart';
import '../../data/helper_models/moneybook_import_plan.dart';
import '../../data/models/moneybook_backup.dart';
import '../../data/repositories/moneybook_backup_repository.dart';
import '../../data/repositories/moneybook_import_repository.dart';
import 'moneybook_import_event.dart';
import 'moneybook_import_state.dart';

class MoneybookImportBloc extends Bloc<MoneybookImportEvent, MoneybookImportState> {
  final MoneybookBackupRepository _moneybookBackupRepository;
  final MoneybookImportRepository _moneybookImportRepository;

  MoneybookImportBloc(this._moneybookBackupRepository, this._moneybookImportRepository) : super(const MoneybookImportInitial()) {
    on<MoneybookBackupSelected>(_onMoneybookBackupSelected);
    on<MoneybookImportConfirmed>(_onMoneybookImportConfirmed);
    on<MoneybookImportReset>(_onMoneybookImportReset);
  }

  Future<void> _onMoneybookBackupSelected(MoneybookBackupSelected event, Emitter<MoneybookImportState> emit) async {
    emit(const MoneybookImportLoading());

    final MoneybookBackup backup;
    try {
      backup = await _moneybookBackupRepository.loadBackup(event.filePath);
    } catch (e) {
      if (e.toString().contains(MoneybookBackupRepository.invalidBackupError)) {
        emit(const MoneybookImportFailure('dataImportInvalidFileError'));
      } else {
        emit(const MoneybookImportFailure('dataImportReadFileError'));
      }
      return;
    }

    try {
      final ExistingImportData existingData = await _moneybookImportRepository.loadExistingData();
      const Uuid uuid = Uuid();
      final MoneybookImportPlan plan = buildMoneybookImportPlan(
        backup: backup,
        existingData: existingData,
        createId: () => uuid.v4(),
        today: DateTime.now(),
      );
      if (plan.hasNothingToImport) {
        emit(const MoneybookImportFailure('dataImportNothingToImportError'));
        return;
      }
      emit(MoneybookImportPreview(plan));
    } catch (e) {
      emit(const MoneybookImportFailure('dataImportDatabaseError'));
    }
  }

  Future<void> _onMoneybookImportConfirmed(MoneybookImportConfirmed event, Emitter<MoneybookImportState> emit) async {
    final MoneybookImportState currentState = state;
    // Verhindert einen doppelten Import, z.B. bei schnellem Doppeltippen.
    if (currentState is! MoneybookImportPreview) {
      return;
    }

    emit(MoneybookImportInProgress(currentState.plan));
    try {
      await _moneybookImportRepository.importPlan(currentState.plan);
      emit(MoneybookImportSuccess(currentState.plan));
    } catch (e) {
      emit(const MoneybookImportFailure('dataImportDatabaseError'));
    }
  }

  void _onMoneybookImportReset(MoneybookImportReset event, Emitter<MoneybookImportState> emit) {
    emit(const MoneybookImportInitial());
  }
}
