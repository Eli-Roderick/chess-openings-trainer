// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Repertoire Trainer';

  @override
  String get settings => 'Settings';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get undo => 'Undo';

  @override
  String get close => 'Close';

  @override
  String get ok => 'OK';

  @override
  String loadError(String error) {
    return 'Something went wrong: $error';
  }

  @override
  String get homeEmptyTitle => 'No repertoires yet';

  @override
  String get homeEmptyBody =>
      'Import an annotated PGN to start training, or try the demo.';

  @override
  String get createRepertoire => 'Create repertoire';

  @override
  String get tryDemo => 'Try the demo';

  @override
  String get newRepertoire => 'New repertoire';

  @override
  String get demoName => 'Demo: Italian (White)';

  @override
  String get demoInstalling => 'Installing the demo…';

  @override
  String lineCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lines',
      one: '1 line',
    );
    return '$_temp0';
  }

  @override
  String get notTrained => 'Not trained';

  @override
  String accuracyValue(int percent) {
    return '$percent %';
  }

  @override
  String dueCount(int count) {
    return '$count due';
  }

  @override
  String weakCount(int count) {
    return '$count weak';
  }

  @override
  String get colorWhite => 'White';

  @override
  String get colorBlack => 'Black';

  @override
  String get repertoireActions => 'Actions';

  @override
  String get rename => 'Rename';

  @override
  String get reimport => 'Re-import PGN';

  @override
  String get exportPgn => 'Export PGN';

  @override
  String get delete => 'Delete';

  @override
  String get validateStored => 'Validate stored PGN';

  @override
  String get renameTitle => 'Rename repertoire';

  @override
  String get nameLabel => 'Name';

  @override
  String deleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get deleteBody => 'Its stats and training history are deleted too.';

  @override
  String deletedSnack(String name) {
    return 'Deleted $name';
  }

  @override
  String exportedSnack(String file) {
    return 'Saved $file';
  }

  @override
  String exportFailed(String error) {
    return 'Could not save the file: $error';
  }

  @override
  String get createTitle => 'New repertoire';

  @override
  String get colourLabel => 'Colour';

  @override
  String get sourceLabel => 'PGN';

  @override
  String get chooseFile => 'Choose file';

  @override
  String get pasteText => 'Paste text';

  @override
  String get pasteHint => 'Paste the PGN here';

  @override
  String get validateAndImport => 'Validate and import';

  @override
  String get validateOnly => 'Validate only';

  @override
  String get copyPrompt => 'Copy annotation prompt';

  @override
  String get promptCopied => 'Annotation prompt copied';

  @override
  String get chooseColourFirst => 'Choose a colour first';

  @override
  String get errorNameRequired => 'Enter a name';

  @override
  String get errorNameTooLong => 'At most 60 characters';

  @override
  String get warningNameExists => 'A repertoire with this name already exists';

  @override
  String get errorColourRequired => 'Choose White or Black';

  @override
  String get errorSourceRequired => 'Choose a file or paste a PGN';

  @override
  String fileReadError(String error) {
    return 'Could not read the file: $error';
  }

  @override
  String get stageReading => 'Reading file';

  @override
  String get stageParsing => 'Parsing';

  @override
  String get stageBuildingLines => 'Building lines';

  @override
  String get stageCheckingComments => 'Checking comments';

  @override
  String importFailed(String error) {
    return 'Import failed: $error';
  }

  @override
  String get importReportTitle => 'Import report';

  @override
  String get reportGames => 'Games merged';

  @override
  String get reportLines => 'Lines';

  @override
  String get reportUserMoves => 'Your moves';

  @override
  String get reportOpponentMoves => 'Opponent moves';

  @override
  String get reportCommented => 'Your moves with comments';

  @override
  String reportCommentedValue(int count, int percent) {
    return '$count ($percent %)';
  }

  @override
  String get reportDepth => 'Deepest line';

  @override
  String reportDepthValue(int plies) {
    return '$plies plies';
  }

  @override
  String reportErrors(int count) {
    return 'Errors ($count)';
  }

  @override
  String reportWarnings(int count) {
    return 'Warnings ($count)';
  }

  @override
  String reportInfo(int count) {
    return 'Info ($count)';
  }

  @override
  String get importAction => 'Import';

  @override
  String get copyReport => 'Copy report';

  @override
  String get reportCopied => 'Report copied';

  @override
  String processedIn(int ms) {
    return 'Processed in $ms ms';
  }

  @override
  String get importBlocked => 'Fix the errors, then validate again.';

  @override
  String get positionPreview => 'Position';

  @override
  String get diffTitle => 'Changes';

  @override
  String get diffUnchanged => 'Unchanged lines (stats kept)';

  @override
  String get diffExtended => 'Extended lines (history carried over)';

  @override
  String get diffNew => 'New lines';

  @override
  String get diffRemoved =>
      'Removed lines (stats archived, restored if the line comes back)';

  @override
  String get diffCommentChanges => 'Your moves with changed comments';

  @override
  String reimportTitle(String name) {
    return 'Re-import $name';
  }

  @override
  String reimportColour(String colour) {
    return 'Colour: $colour (cannot change)';
  }

  @override
  String reimported(String name) {
    return 'Re-imported $name';
  }

  @override
  String get detailAccuracy => 'Accuracy';

  @override
  String get detailCoverage => 'Coverage';

  @override
  String detailCoverageValue(int trained, int total) {
    return '$trained of $total lines trained';
  }

  @override
  String get detailWeak => 'Weak lines';

  @override
  String get detailDue => 'Due today';

  @override
  String get detailNewToday => 'New available today';

  @override
  String get train => 'Train';

  @override
  String get browse => 'Browse';

  @override
  String get stats => 'Stats';

  @override
  String get placeholderTitle => 'Coming soon';

  @override
  String get placeholderBody => 'This screen arrives in a later version.';

  @override
  String get settingsTraining => 'Training';

  @override
  String get settingsBoard => 'Board and sound';

  @override
  String get settingsEngine => 'Engine';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsSync => 'Sync and backup';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsLater => 'These settings arrive in a later version.';

  @override
  String get themeLabel => 'Theme';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String get themeSystem => 'System';

  @override
  String aboutVersion(String version, String build) {
    return 'Version $version ($build)';
  }

  @override
  String get aboutLicense =>
      'Repertoire Trainer is free software licensed under the GNU General Public License, version 3 or later.';

  @override
  String aboutStockfish(String tag) {
    return 'Includes Stockfish $tag (GPL-3.0).';
  }

  @override
  String get aboutLicenses => 'Licenses';

  @override
  String get aboutSource => 'Source code';

  @override
  String get aboutStockfishSource => 'Stockfish source code';

  @override
  String get diagnosticsTitle => 'Diagnostics';

  @override
  String get startupTimings => 'Startup timings';

  @override
  String get processToMain => 'Process start → main';

  @override
  String get mainToRunApp => 'main → runApp';

  @override
  String get runAppToFirstFrame => 'runApp → first frame';

  @override
  String get firstFrameToHome => 'First frame → Home data';

  @override
  String get mainToHome => 'main → Home data';

  @override
  String get notAvailable => 'n/a';

  @override
  String get framesTitle => 'Frames';

  @override
  String get framesCount => 'Frames';

  @override
  String get framesJanky => 'Janky frames (over 16 ms)';

  @override
  String get framesAverageBuild => 'Average build';

  @override
  String get framesAverageRaster => 'Average raster';

  @override
  String get framesWorst => 'Worst frame';

  @override
  String get reset => 'Reset';

  @override
  String msValue(String ms) {
    return '$ms ms';
  }
}
