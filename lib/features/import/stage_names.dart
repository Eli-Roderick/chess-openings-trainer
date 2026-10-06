import 'package:chess_core/chess_core.dart';
import 'package:repertoire_trainer/l10n/gen/app_localizations.dart';

/// Localized name of an import [stage].
String stageName(AppLocalizations l10n, ImportStage stage) => switch (stage) {
  ImportStage.reading => l10n.stageReading,
  ImportStage.parsing => l10n.stageParsing,
  ImportStage.buildingLines => l10n.stageBuildingLines,
  ImportStage.checkingComments => l10n.stageCheckingComments,
};
