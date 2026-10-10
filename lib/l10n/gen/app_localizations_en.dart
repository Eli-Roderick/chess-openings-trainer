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
  String get framesJanky => 'Frames over budget';

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

  @override
  String get noComment => 'No comment for this move';

  @override
  String get commentWhy => 'Why';

  @override
  String get commentPlan => 'Plan';

  @override
  String get commentWatch => 'Watch out';

  @override
  String get commentAlternatives => 'Alternatives';

  @override
  String get showAlternatives => 'Show alternatives';

  @override
  String get hideAlternatives => 'Hide alternatives';

  @override
  String get browseTitle => 'Browse';

  @override
  String get browseStart => 'Start position';

  @override
  String get browseFirst => 'First move';

  @override
  String get browseBack => 'Back';

  @override
  String get browseForward => 'Forward';

  @override
  String get browseLast => 'Last move';

  @override
  String get flipBoard => 'Flip board';

  @override
  String get chooseMove => 'Choose a move';

  @override
  String get backToRepertoire => 'Back to repertoire';

  @override
  String get exploring => 'Exploring (not saved)';

  @override
  String get opponentMoveNoComment => 'Opponent move';

  @override
  String get boardSettingsTitle => 'Board and sound';

  @override
  String get boardTheme => 'Board theme';

  @override
  String get pieceSet => 'Piece set';

  @override
  String get showCoordinates => 'Coordinates';

  @override
  String get showLegalMoves => 'Legal move dots';

  @override
  String get highlightLastMove => 'Highlight last move';

  @override
  String get animationSpeed => 'Animation speed';

  @override
  String get animationSlow => 'Slow';

  @override
  String get animationNormal => 'Normal';

  @override
  String get animationFast => 'Fast';

  @override
  String get animationOff => 'Off';

  @override
  String get soundsEnabled => 'Sounds';

  @override
  String get soundVolume => 'Volume';

  @override
  String get hapticsEnabled => 'Haptics';

  @override
  String get framesSlowBuilds => 'Slow builds (UI thread)';

  @override
  String get framesSlowRasters => 'Slow rasters';

  @override
  String get analysisToggle => 'Analysis';

  @override
  String get engineUnavailable => 'Engine unavailable';

  @override
  String get analysing => 'Analysing…';

  @override
  String analysisDepth(int depth) {
    return 'Depth $depth';
  }

  @override
  String engineThreadsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count threads',
      one: '1 thread',
    );
    return '$_temp0';
  }

  @override
  String engineMnps(String value) {
    return '$value Mnps';
  }

  @override
  String get engineReady => 'ready';

  @override
  String get engineNotRunning => 'not running';

  @override
  String get engineStarting => 'starting…';

  @override
  String engineError(String message) {
    return 'error ($message); restarts on the next search';
  }

  @override
  String engineUnavailableStatus(String message) {
    return 'unavailable ($message). Tap Restart engine.';
  }

  @override
  String get comparableThreshold => 'Comparable threshold';

  @override
  String pawnsValue(String value) {
    return '$value pawns';
  }

  @override
  String get checkSearchTime => 'Check search time';

  @override
  String secondsValue(String value) {
    return '$value s';
  }

  @override
  String get engineThreads => 'Threads';

  @override
  String get engineHash => 'Hash';

  @override
  String autoValue(String value) {
    return 'Auto ($value)';
  }

  @override
  String get playOnStrength => 'Play-on strength';

  @override
  String get fullStrength => 'Full';

  @override
  String get calibration => 'Calibration';

  @override
  String get notCalibrated => 'Not calibrated yet';

  @override
  String calibrationValue(String mnps, int depth) {
    return '$mnps Mnps · depth $depth in 1 s';
  }

  @override
  String get runCalibration => 'Run calibration';

  @override
  String get slowDeviceNote =>
      'This device usually needs more than 1 s per check; banners may appear a little later.';

  @override
  String get restartEngine => 'Restart engine';

  @override
  String get engineTitle => 'Engine';

  @override
  String get engineBinary => 'Binary';

  @override
  String get engineMissing => 'Not found';

  @override
  String get engineVariant => 'Variant';

  @override
  String get engineVersion => 'Version';

  @override
  String get engineState => 'State';

  @override
  String get calibrationNps => 'Calibration nps';

  @override
  String get calibrationDepth2s => 'Depth in 2 s';

  @override
  String get calibrationDepth1s => 'Median depth in 1 s';

  @override
  String get engineRecentJobs => 'Last jobs';

  @override
  String get trainTitle => 'Train';

  @override
  String get modeRandom => 'Random';

  @override
  String get trainingSettings => 'Training settings';

  @override
  String get noTrainableLines =>
      'This repertoire has no line with moves of your colour.';

  @override
  String get yourMove => 'Your move';

  @override
  String get opponentToMove => 'Opponent to move';

  @override
  String skippedToMove(int move) {
    return 'Skipped to move $move';
  }

  @override
  String get comparableBanner =>
      'That is not the move in your repertoire, but it is a comparable move.';

  @override
  String get notRepertoireMove => 'Not your repertoire move';

  @override
  String bannerWithMove(String move, String text) {
    return '$move: $text';
  }

  @override
  String runAccuracy(String credit, int graded, int percent) {
    return '$credit/$graded · $percent %';
  }

  @override
  String get hint => 'Hint';

  @override
  String get showMove => 'Show move';

  @override
  String moveProgress(int current, int total) {
    return 'Move $current of $total';
  }

  @override
  String get skipLine => 'Skip line';

  @override
  String get nextLine => 'Next line';

  @override
  String get sessionSummary => 'Session';

  @override
  String linesCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lines completed',
      one: '1 line completed',
    );
    return '$_temp0';
  }

  @override
  String sessionAccuracy(int percent) {
    return 'Accuracy $percent %';
  }

  @override
  String get done => 'Done';

  @override
  String get wrongMoveBehaviour => 'Wrong move behaviour';

  @override
  String get wrongMoveRetry => 'Retry';

  @override
  String get wrongMoveRestart => 'Restart line';

  @override
  String get startFrom => 'Start from';

  @override
  String get startFromMove1 => 'Move 1';

  @override
  String get startFromBranch => 'Branch point';

  @override
  String get autoAdvanceDelay => 'Auto-advance delay';

  @override
  String get opponentDelay => 'Opponent move delay';

  @override
  String get showCommentsInDrills => 'Show comments during drills';

  @override
  String get showCommentArrows => 'Show comment arrows';

  @override
  String get drillEvalBar => 'Eval bar in drills';

  @override
  String get toggleEvalBar => 'Toggle eval bar';

  @override
  String get drillLatency => 'Drill latency';

  @override
  String get latencyP50 => 'Median';

  @override
  String get latencyP95 => '95th percentile';

  @override
  String get latencySamples => 'Samples';

  @override
  String get modeWeak => 'Weak lines';

  @override
  String modeWeakCount(int count) {
    return 'Weak $count';
  }

  @override
  String get modeSrs => 'Spaced repetition';

  @override
  String modeSrsLeft(int count) {
    return 'SRS $count left';
  }

  @override
  String get modeSingle => 'Single line';

  @override
  String get summary => 'Summary';

  @override
  String get noWeakLines => 'No weak lines. Nice.';

  @override
  String get srsLimitReached => 'Daily review limit reached.';

  @override
  String get allCaughtUp => 'All caught up.';

  @override
  String allCaughtUpNext(String date, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lines',
      one: '1 line',
    );
    return 'All caught up. Next review: $date ($_temp0)';
  }

  @override
  String get trainWeakLines => 'Train weak lines';

  @override
  String lineAccuracyChange(String before, String after) {
    return 'Line accuracy (last 10): $before → $after';
  }

  @override
  String get enteredWeakPool => 'Entered weak pool';

  @override
  String get leftWeakPool => 'Left weak pool';

  @override
  String srsNextDue(String date) {
    return 'Next review: $date';
  }

  @override
  String get retryThisLine => 'Retry this line';

  @override
  String get browseThisLine => 'Browse this line';

  @override
  String youPlayed(String move) {
    return 'You played $move';
  }

  @override
  String get hintUsed => 'Hint used';

  @override
  String get modeRandomHint =>
      'All lines, weighted towards weak and stale ones';

  @override
  String weakPoolSize(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lines in the pool',
      one: '1 line in the pool',
    );
    return '$_temp0';
  }

  @override
  String get weakPoolEmptyHint =>
      'No weak lines yet: lines enter the pool below the accuracy threshold.';

  @override
  String srsCounts(int due, int fresh) {
    return '$due due, $fresh new available';
  }

  @override
  String get opponentDeviations => 'Opponent deviations';

  @override
  String get start => 'Start';

  @override
  String continueTraining(String name, String mode) {
    return 'Continue: $name · $mode';
  }

  @override
  String get showLineSummary => 'Show line summary';

  @override
  String get weakEnterBelow => 'Weak pool: enter below accuracy';

  @override
  String get weakExitAfter => 'Weak pool: leave after clean runs';

  @override
  String get srsNewPerDay => 'SRS: new lines per day';

  @override
  String get srsMaxReviews => 'SRS: max reviews per day';

  @override
  String get unlimited => 'Unlimited';

  @override
  String get dayStartsAt => 'Day starts at';

  @override
  String percentValue(int value) {
    return '$value %';
  }

  @override
  String get deviationsThisSession => 'This session only';

  @override
  String get deviationChance => 'Deviation chance per line';

  @override
  String get deviationTiming => 'Deviation timing';

  @override
  String get timingEndOfLine => 'End of line';

  @override
  String get timingAnywhere => 'Anywhere in the line';

  @override
  String get checkingReply => 'Checking your reply…';

  @override
  String get goodReply => 'Good reply';

  @override
  String get inaccurate => 'Inaccurate';

  @override
  String inaccurateBestWas(String san) {
    return 'Inaccurate. Best was $san';
  }

  @override
  String get deviationMidLine =>
      'Opponent left your repertoire. Find a good reply.';

  @override
  String get deviationEndPlaysOn =>
      'Your repertoire ends here. The opponent plays on: find a good reply.';

  @override
  String get deviationEndFindMove =>
      'Your repertoire ends here. Find a good move.';

  @override
  String get hintFailsReply => 'Hint used: this reply counts as missed.';

  @override
  String get playOn => 'Play on';

  @override
  String playOnTitle(String strength) {
    return 'Play on · $strength';
  }

  @override
  String get strengthClub => 'Club 1500';

  @override
  String get strengthStrong => 'Strong 2000';

  @override
  String get strengthExpert => 'Expert 2500';

  @override
  String get backToTraining => 'Back to training';

  @override
  String get takeBack => 'Take back';

  @override
  String get analyse => 'Analyse';

  @override
  String get engineThinking => 'Engine thinking…';

  @override
  String get resultUserMates => 'Checkmate. You win.';

  @override
  String get resultEngineMates => 'Checkmate. The engine wins.';

  @override
  String get resultStalemate => 'Stalemate. Draw.';

  @override
  String get resultThreefold => 'Threefold repetition. Draw.';

  @override
  String get resultFiftyMoves => '50-move rule. Draw.';

  @override
  String get resultInsufficient => 'Insufficient material. Draw.';

  @override
  String get deviationJobs => 'Deviation candidates';

  @override
  String get deviationReadyRate => 'Ready when needed';

  @override
  String deviationReadyValue(int percent, int count) {
    return '$percent % of $count';
  }

  @override
  String get deviationJobCount => 'Jobs';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-day streak',
      one: '1-day streak',
    );
    return '$_temp0';
  }

  @override
  String streakBest(int count) {
    return 'Best: $count';
  }

  @override
  String get streakDone => 'Done today';

  @override
  String get streakKeep => 'Train one line to keep your streak';

  @override
  String sessionStreak(int count, String done) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    String _temp1 = intl.Intl.selectLogic(done, {
      'true': ', today done',
      'other': '',
    });
    return 'Streak: $_temp0$_temp1';
  }

  @override
  String statsOf(String name) {
    return 'Stats · $name';
  }

  @override
  String get statsAccuracy => 'Accuracy';

  @override
  String get statsCoverage => 'Coverage';

  @override
  String get statsWeak => 'Weak lines';

  @override
  String get statsDue => 'Due today';

  @override
  String get statsRuns => 'Runs';

  @override
  String get statsStreak => 'Streak';

  @override
  String get accuracyOverTime => 'Accuracy over time';

  @override
  String get range30 => '30 d';

  @override
  String get range90 => '90 d';

  @override
  String get rangeAll => 'All';

  @override
  String get noRunsYet => 'No runs yet';

  @override
  String get worstLines => 'Worst lines';

  @override
  String get showAll => 'Show all';

  @override
  String get mostMissedMoves => 'Most missed moves';

  @override
  String get noMissedMoves => 'No move missed yet (at least 3 attempts).';

  @override
  String missedOf(String move, int misses, int attempts) {
    return '$move (missed $misses of $attempts)';
  }

  @override
  String get deviationReplies => 'Deviation replies';

  @override
  String deviationRepliesSummary(int count, int percent) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count replies',
      one: '1 reply',
    );
    return '$_temp0 · $percent % good';
  }

  @override
  String get allLines => 'All lines';

  @override
  String get sortBy => 'Sort by';

  @override
  String get sortAccuracy => 'Accuracy';

  @override
  String get sortLastPlayed => 'Last played';

  @override
  String get sortRuns => 'Runs';

  @override
  String get sortOrder => 'Line order';

  @override
  String get filterAll => 'All';

  @override
  String get filterWeak => 'Weak only';

  @override
  String get filterUntrained => 'Untrained';

  @override
  String get filterArchived => 'Archived';

  @override
  String lineRunsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count runs',
      one: '1 run',
    );
    return '$_temp0';
  }

  @override
  String get lineDetail => 'Line';

  @override
  String get notInCurrentPgn => 'Not in current PGN';

  @override
  String get weakPool => 'Weak pool';

  @override
  String get notWeak => 'Not weak';

  @override
  String weakCleanRuns(int done, int needed) {
    return 'In pool · clean runs $done of $needed';
  }

  @override
  String get srsState => 'Spaced repetition';

  @override
  String get srsNew => 'New';

  @override
  String srsStateValue(String date, int days, String ease) {
    return 'Due $date · every $days d · ease $ease';
  }

  @override
  String get drillThisLine => 'Drill this line';

  @override
  String get moveErrors => 'Errors per move';

  @override
  String missedCount(int misses, int attempts) {
    return 'missed $misses of $attempts';
  }

  @override
  String get runHistory => 'Run history';

  @override
  String get abandoned => 'abandoned';

  @override
  String get syncTitle => 'Google Drive sync';

  @override
  String get backupTitle => 'Backup';

  @override
  String get exportBackup => 'Export backup';

  @override
  String get exportBackupHint =>
      'Repertoires, training history and settings in one file';

  @override
  String get importBackup => 'Import backup';

  @override
  String get importBackupHint =>
      'Merge a backup file into this device, or replace everything';

  @override
  String get backupExporting => 'Preparing the backup…';

  @override
  String get backupReading => 'Reading the backup…';

  @override
  String get backupImporting => 'Importing…';

  @override
  String backupSaved(String where) {
    return 'Backup saved: $where';
  }

  @override
  String backupFailed(String error) {
    return 'Backup failed: $error';
  }

  @override
  String get backupNewer =>
      'This backup is from a newer app version. Update this device first.';

  @override
  String get backupInvalid => 'Not a Repertoire Trainer backup.';

  @override
  String backupContents(int repertoires, int runs, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      repertoires,
      locale: localeName,
      other: '$repertoires repertoires',
      one: '1 repertoire',
    );
    String _temp1 = intl.Intl.pluralLogic(
      runs,
      locale: localeName,
      other: '$runs runs',
      one: '1 run',
    );
    return '$_temp0, $_temp1, exported $date';
  }

  @override
  String get importMerge => 'Merge';

  @override
  String get importMergeHint =>
      'Keeps everything on this device; newer repertoire changes win, all runs are kept.';

  @override
  String get replaceAll => 'Replace all';

  @override
  String get importReplaceHint =>
      'Deletes this device\'s repertoires and runs first.';

  @override
  String get restoreSettings => 'Also restore settings';

  @override
  String get replaceAllTitle => 'Replace all?';

  @override
  String replaceAllBody(int repertoires, int runs) {
    String _temp0 = intl.Intl.pluralLogic(
      repertoires,
      locale: localeName,
      other: '$repertoires repertoires',
      one: '1 repertoire',
    );
    String _temp1 = intl.Intl.pluralLogic(
      runs,
      locale: localeName,
      other: '$runs runs',
      one: '1 run',
    );
    return 'This deletes $_temp0 and $_temp1 on this device before importing.';
  }

  @override
  String backupImported(int repertoires, int runs) {
    String _temp0 = intl.Intl.pluralLogic(
      repertoires,
      locale: localeName,
      other: '$repertoires repertoires',
      one: '1 repertoire',
    );
    String _temp1 = intl.Intl.pluralLogic(
      runs,
      locale: localeName,
      other: '$runs runs',
      one: '1 run',
    );
    return 'Backup imported: $_temp0 updated, $_temp1 added.';
  }

  @override
  String updatedFromOtherDevice(String name) {
    return '$name was updated from another device.';
  }

  @override
  String get deletedOnOtherDevice =>
      'This repertoire was deleted on another device.';

  @override
  String get syncNotConfigured => 'Sync is not configured in this build.';

  @override
  String get syncToggle => 'Sync with Google Drive';

  @override
  String get syncOffHint =>
      'Keeps repertoires and training history the same on your phone and computer.';

  @override
  String get syncSignedIn => 'Signed in';

  @override
  String syncSignedInAs(String account) {
    return 'Signed in as $account';
  }

  @override
  String get syncNever => 'never';

  @override
  String syncLast(String when) {
    return 'Last sync: $when';
  }

  @override
  String get syncRunning => 'Syncing…';

  @override
  String get syncOffline => 'Offline, will retry';

  @override
  String get syncSignInAgain => 'Sign in again to keep syncing.';

  @override
  String syncError(String message) {
    return 'Sync failed: $message';
  }

  @override
  String syncFailed(String error) {
    return 'Sync failed: $error';
  }

  @override
  String get syncNewerDevice =>
      'Another device uses a newer app version. Update this device.';

  @override
  String get syncCorruptFile =>
      'A file from another device could not be read; it was skipped.';

  @override
  String get signInAgain => 'Sign in again';

  @override
  String get syncNow => 'Sync now';

  @override
  String get signOut => 'Sign out';

  @override
  String get deleteCloudData => 'Delete cloud data';

  @override
  String get deleteCloudTitle => 'Delete cloud data?';

  @override
  String get deleteCloudBody =>
      'Deletes the sync files of all your devices from Google Drive. Data on this device stays.';

  @override
  String cloudDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files deleted',
      one: '1 file deleted',
    );
    return '$_temp0';
  }

  @override
  String get syncHelp =>
      'Sync uses a hidden app folder in your Google Drive. A device with a wrong clock can win or lose a rename or re-import; training history is never lost.';

  @override
  String get replaceSyncWarning =>
      'Sync is on: the next sync brings back data from your other devices unless you also delete the cloud data.';

  @override
  String get deviceIdLabel => 'Device id';

  @override
  String get syncPhaseLabel => 'State';

  @override
  String get syncMessageLabel => 'Message';

  @override
  String get listDriveFiles => 'List Drive files';

  @override
  String openFileTitle(String name) {
    return 'Open $name';
  }

  @override
  String reimportInto(String name) {
    return 'Re-import into $name';
  }

  @override
  String get shortcutList => 'Keyboard shortcuts';

  @override
  String get shortcutsAnywhere => 'Anywhere';

  @override
  String get shortcutsDrill => 'Drill';

  @override
  String get shortcutsBrowse => 'Browse';

  @override
  String get shortcutLeave => 'Leave the screen';

  @override
  String get shortcutHint => 'Hint, then show the move';

  @override
  String get shortcutBackForward => 'Back / forward one move';

  @override
  String get shortcutForward => 'Forward (or the chooser at a fork)';

  @override
  String get shortcutStartEnd => 'Start / end of the line';

  @override
  String get shortcutSiblings => 'Previous / next sibling move';

  @override
  String get logsTitle => 'Logs';

  @override
  String get exportLogs => 'Export logs';

  @override
  String get logsExported => 'Logs saved';

  @override
  String get logsUnavailable => 'No log files on this device';

  @override
  String logsExportFailed(String error) {
    return 'Could not save the logs: $error';
  }

  @override
  String get showVariations => 'Show variations';

  @override
  String get hideVariations => 'Hide variations';

  @override
  String get framesBudget => 'Budget (display refresh rate)';

  @override
  String get framesOverBudget => 'Over budget';

  @override
  String percentDecimal(String value) {
    return '$value %';
  }

  @override
  String get framesWorstRaster => 'Worst raster';

  @override
  String get databaseTitle => 'Database';

  @override
  String get databaseFileSize => 'File size';

  @override
  String get databaseLastDerivation => 'Last derivation';

  @override
  String get refresh => 'Refresh';

  @override
  String get importBenchmark => 'Import benchmark';

  @override
  String get importBenchmarkHint =>
      'Imports a 1,000-line synthetic PGN into a temporary repertoire, then deletes it';

  @override
  String get importBenchmarkRunning => 'Running…';

  @override
  String importBenchmarkResult(int lines, int total, int import, int store) {
    return '$lines lines: $total ms (import $import ms, store $store ms)';
  }

  @override
  String get gameReview => 'Game Review';

  @override
  String get chessComUsername => 'chess.com username';

  @override
  String get fetchGames => 'Fetch games';

  @override
  String get needsInternet => 'Needs an internet connection';

  @override
  String get gamesOffline =>
      'You are offline. Fetching games needs internet; saved games still open.';

  @override
  String get checkConnection => 'Check again';

  @override
  String get archiveDelayNote =>
      'chess.com updates its archives with a delay, so a game you just finished may not show yet.';

  @override
  String get invalidUsername =>
      'Enter a chess.com username: 3 to 25 letters, digits, _ or -.';

  @override
  String get userNotFound => 'No chess.com account has that name.';

  @override
  String get chessComBusy => 'chess.com is busy. Try again in a minute.';

  @override
  String chessComError(int status) {
    return 'chess.com answered with an error ($status).';
  }

  @override
  String newGames(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new games',
      one: '1 new game',
      zero: 'No new games',
    );
    return '$_temp0';
  }

  @override
  String get loadOlderGames => 'Load older games';

  @override
  String get allGamesLoaded => 'All games loaded';

  @override
  String get noGamesYet =>
      'No games yet. Enter a chess.com username and fetch.';

  @override
  String gameOpponent(String name, int rating) {
    return 'vs $name ($rating)';
  }

  @override
  String get resultWin => 'Win';

  @override
  String get resultDraw => 'Draw';

  @override
  String get resultLoss => 'Loss';

  @override
  String get timeClassBullet => 'Bullet';

  @override
  String get timeClassBlitz => 'Blitz';

  @override
  String get timeClassRapid => 'Rapid';

  @override
  String get timeClassDaily => 'Daily';

  @override
  String timeControlDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$_temp0 per move';
  }

  @override
  String get playedWhite => 'You played White';

  @override
  String get playedBlack => 'You played Black';

  @override
  String get analyseRecentGames => 'Analyse recent games';

  @override
  String analysingGame(int index, int total) {
    return 'Analysing game $index of $total';
  }

  @override
  String get stopAnalysis => 'Stop';

  @override
  String get analysisStoppedBattery => 'Analysis stopped: battery low.';

  @override
  String gameAccuracy(String value) {
    return 'Accuracy $value';
  }

  @override
  String get moveLabelBook => 'Book';

  @override
  String get moveLabelForced => 'Forced';

  @override
  String get moveLabelBrilliant => 'Brilliant';

  @override
  String get moveLabelGreat => 'Great';

  @override
  String get moveLabelBest => 'Best';

  @override
  String get moveLabelExcellent => 'Excellent';

  @override
  String get moveLabelGood => 'Good';

  @override
  String get moveLabelInaccuracy => 'Inaccuracy';

  @override
  String get moveLabelMistake => 'Mistake';

  @override
  String get moveLabelBlunder => 'Blunder';

  @override
  String get moveLabelMiss => 'Miss';

  @override
  String get analysisQuick => 'Quick';

  @override
  String get analysisStandard => 'Standard';

  @override
  String reviewBestWas(String best) {
    return 'Best was $best';
  }

  @override
  String reviewTimeSpent(String seconds) {
    return '$seconds s';
  }

  @override
  String get reviewStart => 'Start position';

  @override
  String retryPrompt(String san) {
    return 'Find a better move than $san.';
  }

  @override
  String get retryWrong => 'Not the best move. Try again.';

  @override
  String retryCorrect(String san) {
    return 'Correct: $san was best.';
  }

  @override
  String get retryExit => 'Back to review';

  @override
  String get gameNotFound => 'This game is no longer stored.';

  @override
  String get repertoireLink => 'Repertoire';

  @override
  String get linkNoRepertoire => 'No repertoire for this colour.';

  @override
  String linkUserLeft(String move, String san, String book) {
    return 'You left the repertoire at $move $san. The repertoire plays $book.';
  }

  @override
  String linkOpponentLeft(String move, String san) {
    return 'Your opponent left the repertoire at $move $san. Not covered yet.';
  }

  @override
  String linkRepertoireEnd(String move, String san) {
    return 'The game followed the repertoire to its end; $move $san came after it.';
  }

  @override
  String get linkGameEnd => 'The game ended inside the repertoire.';

  @override
  String linkRecord(int wins, int draws, int losses) {
    return 'Your games reaching this position: $wins W, $draws D, $losses L';
  }

  @override
  String get addToRepertoire => 'Add to repertoire';

  @override
  String get uncoveredReplies => 'Uncovered opponent replies in your games';

  @override
  String uncoveredReply(String move, String san, String path, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count games',
      one: '1 game',
    );
    return '$move $san after $path: $_temp0';
  }

  @override
  String get summaryIntro => 'Let\'s review some key moments from your game.';

  @override
  String get summaryPlayers => 'Players';

  @override
  String get summaryAccuracy => 'Accuracy';

  @override
  String get summaryRating => 'Game rating (estimate)';

  @override
  String get continueReview => 'Continue review';

  @override
  String get reviewNext => 'Next';

  @override
  String get reviewShow => 'Show';

  @override
  String get reviewBest => 'Best';

  @override
  String get reviewRetry => 'Retry';

  @override
  String get backToSummary => 'Summary';

  @override
  String reviewOpening(String name) {
    return 'Opening: $name';
  }

  @override
  String reviewLine(String line) {
    return 'Engine line: $line';
  }

  @override
  String moveTitleBook(String san) {
    return '$san is a book move';
  }

  @override
  String moveTitleForced(String san) {
    return '$san was forced';
  }

  @override
  String moveTitleBrilliant(String san) {
    return '$san is brilliant';
  }

  @override
  String moveTitleGreat(String san) {
    return '$san is a great move';
  }

  @override
  String moveTitleBest(String san) {
    return '$san is the best move';
  }

  @override
  String moveTitleExcellent(String san) {
    return '$san is excellent';
  }

  @override
  String moveTitleGood(String san) {
    return '$san is good';
  }

  @override
  String moveTitleInaccuracy(String san) {
    return '$san is an inaccuracy';
  }

  @override
  String moveTitleMistake(String san) {
    return '$san is a mistake';
  }

  @override
  String moveTitleBlunder(String san) {
    return '$san is a blunder';
  }

  @override
  String moveTitleMiss(String san) {
    return '$san is a miss';
  }

  @override
  String reviewAnalysing(String profile, int done, int total) {
    return 'Analysing ($profile) $done / $total';
  }

  @override
  String selectedCount(int count) {
    return '$count selected';
  }

  @override
  String get selectAllGames => 'Select all';

  @override
  String get reviewSelected => 'Review selected games';

  @override
  String get rerunSelected => 'Re-run selected reviews';

  @override
  String get clearSelection => 'Clear selection';

  @override
  String get rerunReview => 'Re-run review';

  @override
  String get rerunReviewTitle => 'Re-run this review?';

  @override
  String get rerunReviewBody =>
      'The stored analysis of this game is replaced by a new one. It takes a minute or two.';

  @override
  String get rerunConfirm => 'Re-run';

  @override
  String get summaryChessComAccuracy => 'chess.com accuracy';

  @override
  String summaryCapped(int count) {
    return '$count positions hit the time limit and were searched less deeply than Standard depth, so these scores may be slightly off.';
  }

  @override
  String get calibrateScores => 'Fit accuracy to chess.com';

  @override
  String get calibrateTitle => 'Fit accuracy to chess.com';

  @override
  String calibrateTooFew(int count) {
    return 'Needs at least $count reviewed games that carry chess.com\'s own accuracy. Fetch the games again, then analyse them.';
  }

  @override
  String calibrateDone(int games, String decay, String error, String bias) {
    return 'Fitted to $games player-games: decay $decay, mean difference to chess.com $error points (bias $bias). All reviewed games were re-scored.';
  }
}
