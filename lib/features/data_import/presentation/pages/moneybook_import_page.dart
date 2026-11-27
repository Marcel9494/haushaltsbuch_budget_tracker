import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/moneybook_import/moneybook_import_bloc.dart';
import '../../../../blocs/moneybook_import/moneybook_import_event.dart';
import '../../../../blocs/moneybook_import/moneybook_import_state.dart';
import '../../../../core/consts/route_consts.dart';
import '../../../../core/page_arguments/home_page_arguments.dart';
import '../../../../core/utils/app_flushbar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../shared/presentation/widgets/deco/circular_loading_indicator.dart';
import '../../../shared/presentation/widgets/deco/error_text.dart';
import '../widgets/cards/import_info_card.dart';
import '../widgets/cards/import_summary_card.dart';

// Importiert Buchungen, Konten, Kategorien, Budgets und Ziele aus einer Moneybook-Sicherung.
class MoneybookImportPage extends StatelessWidget {
  const MoneybookImportPage({super.key});

  Future<void> _selectBackupFile(BuildContext context) async {
    final t = AppLocalizations.of(context);
    final MoneybookImportBloc moneybookImportBloc = context.read<MoneybookImportBloc>();
    try {
      // Die Endung .db ist auf vielen Geräten kein bekannter Dateityp, daher werden alle Dateien angeboten.
      // Ob die Datei eine Moneybook-Sicherung ist, prüft das Repository beim Lesen.
      final FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);
      final String? filePath = result?.files.single.path;
      if (filePath != null) {
        moneybookImportBloc.add(MoneybookBackupSelected(filePath: filePath));
      }
    } catch (_) {
      if (context.mounted) {
        AppFlushbar.show(context, message: t.translate('dataImportOpenFileError'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return BlocBuilder<MoneybookImportBloc, MoneybookImportState>(
      builder: (context, state) {
        final bool isImporting = state is MoneybookImportInProgress;
        return PopScope(
          // Während des Imports darf die Seite nicht verlassen werden.
          canPop: !isImporting,
          child: Scaffold(
            appBar: AppBar(
              title: Text(t.translate('dataImportTitle')),
              automaticallyImplyLeading: !isImporting,
            ),
            body: SafeArea(
              child: _buildBody(context, state),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, MoneybookImportState state) {
    final t = AppLocalizations.of(context);

    if (state is MoneybookImportLoading) {
      return const CircularLoadingIndicator();
    }

    if (state is MoneybookImportInProgress) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularLoadingIndicator(),
              const SizedBox(height: 24.0),
              Text(t.translate('dataImportInProgress'), textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    if (state is MoneybookImportPreview) {
      return ListView(
        padding: const EdgeInsets.all(12.0),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 8.0),
            child: Text(
              t.translate('dataImportPreviewTitle'),
              style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ),
          ImportSummaryCard(plan: state.plan),
          ImportInfoCard(
            icon: Icons.warning_amber_rounded,
            iconColor: Colors.orangeAccent,
            title: t.translate('dataImportNoticeTitle'),
            paragraphs: [
              t.translate('dataImportDuplicateNotice'),
              t.translate('dataImportReuseNotice'),
              t.translate('dataImportInvestmentNotice'),
            ],
          ),
          const SizedBox(height: 16.0),
          ElevatedButton.icon(
            onPressed: () => context.read<MoneybookImportBloc>().add(const MoneybookImportConfirmed()),
            icon: const Icon(Icons.download_done_rounded),
            label: Text(t.translate('dataImportStartButton')),
          ),
          const SizedBox(height: 8.0),
          TextButton(
            onPressed: () => _selectBackupFile(context),
            child: Text(t.translate('dataImportOtherFileButton')),
          ),
        ],
      );
    }

    if (state is MoneybookImportSuccess) {
      return ListView(
        padding: const EdgeInsets.all(12.0),
        children: [
          const SizedBox(height: 24.0),
          const Icon(Icons.check_circle_rounded, size: 64.0, color: Colors.greenAccent),
          const SizedBox(height: 16.0),
          Text(
            t.translate('dataImportSuccessTitle'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          Text(t.translate('dataImportSuccessDescription'), textAlign: TextAlign.center),
          const SizedBox(height: 16.0),
          ImportSummaryCard(plan: state.plan),
          const SizedBox(height: 16.0),
          ElevatedButton(
            // Startseite neu aufbauen, damit alle Listen die importierten Daten laden.
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
              homeRoute,
              (route) => false,
              arguments: HomePageArguments(0),
            ),
            child: Text(t.translate('dataImportToOverviewButton')),
          ),
        ],
      );
    }

    if (state is MoneybookImportFailure) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Expanded(child: ErrorText(errorMessage: state.message)),
            ElevatedButton(
              onPressed: () => context.read<MoneybookImportBloc>().add(const MoneybookImportReset()),
              child: Text(t.translate('dataImportTryAgainButton')),
            ),
          ],
        ),
      );
    }

    // MoneybookImportInitial
    return ListView(
      padding: const EdgeInsets.all(12.0),
      children: [
        ImportInfoCard(
          icon: Icons.upload_file_rounded,
          title: t.translate('dataImportInfoTitle'),
          paragraphs: [
            t.translate('dataImportDescription'),
            t.translate('dataImportExportInstruction'),
          ],
        ),
        ImportInfoCard(
          icon: Icons.warning_amber_rounded,
          iconColor: Colors.orangeAccent,
          title: t.translate('dataImportNoticeTitle'),
          paragraphs: [
            t.translate('dataImportDuplicateNotice'),
            t.translate('dataImportReuseNotice'),
          ],
        ),
        const SizedBox(height: 16.0),
        ElevatedButton.icon(
          onPressed: () => _selectBackupFile(context),
          icon: const Icon(Icons.folder_open_rounded),
          label: Text(t.translate('dataImportSelectFileButton')),
        ),
      ],
    );
  }
}
