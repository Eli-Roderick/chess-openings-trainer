import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Repertoire Trainer'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @loadError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong: {error}'**
  String loadError(String error);

  /// No description provided for @homeEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No repertoires yet'**
  String get homeEmptyTitle;

  /// No description provided for @homeEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Import an annotated PGN to start training, or try the demo.'**
  String get homeEmptyBody;

  /// No description provided for @createRepertoire.
  ///
  /// In en, this message translates to:
  /// **'Create repertoire'**
  String get createRepertoire;

  /// No description provided for @tryDemo.
  ///
  /// In en, this message translates to:
  /// **'Try the demo'**
  String get tryDemo;

  /// No description provided for @newRepertoire.
  ///
  /// In en, this message translates to:
  /// **'New repertoire'**
  String get newRepertoire;

  /// No description provided for @demoName.
  ///
  /// In en, this message translates to:
  /// **'Demo: Italian (White)'**
  String get demoName;

  /// No description provided for @demoInstalling.
  ///
  /// In en, this message translates to:
  /// **'Installing the demo…'**
  String get demoInstalling;

  /// No description provided for @lineCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 line} other{{count} lines}}'**
  String lineCount(int count);

  /// No description provided for @notTrained.
  ///
  /// In en, this message translates to:
  /// **'Not trained'**
  String get notTrained;

  /// No description provided for @accuracyValue.
  ///
  /// In en, this message translates to:
  /// **'{percent} %'**
  String accuracyValue(int percent);

  /// No description provided for @dueCount.
  ///
  /// In en, this message translates to:
  /// **'{count} due'**
  String dueCount(int count);

  /// No description provided for @weakCount.
  ///
  /// In en, this message translates to:
  /// **'{count} weak'**
  String weakCount(int count);

  /// No description provided for @colorWhite.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get colorWhite;

  /// No description provided for @colorBlack.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get colorBlack;

  /// No description provided for @repertoireActions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get repertoireActions;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @reimport.
  ///
  /// In en, this message translates to:
  /// **'Re-import PGN'**
  String get reimport;

  /// No description provided for @exportPgn.
  ///
  /// In en, this message translates to:
  /// **'Export PGN'**
  String get exportPgn;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @validateStored.
  ///
  /// In en, this message translates to:
  /// **'Validate stored PGN'**
  String get validateStored;

  /// No description provided for @renameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename repertoire'**
  String get renameTitle;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @deleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String deleteTitle(String name);

  /// No description provided for @deleteBody.
  ///
  /// In en, this message translates to:
  /// **'Its stats and training history are deleted too.'**
  String get deleteBody;

  /// No description provided for @deletedSnack.
  ///
  /// In en, this message translates to:
  /// **'Deleted {name}'**
  String deletedSnack(String name);

  /// No description provided for @exportedSnack.
  ///
  /// In en, this message translates to:
  /// **'Saved {file}'**
  String exportedSnack(String file);

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the file: {error}'**
  String exportFailed(String error);

  /// No description provided for @createTitle.
  ///
  /// In en, this message translates to:
  /// **'New repertoire'**
  String get createTitle;

  /// No description provided for @colourLabel.
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get colourLabel;

  /// No description provided for @sourceLabel.
  ///
  /// In en, this message translates to:
  /// **'PGN'**
  String get sourceLabel;

  /// No description provided for @chooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose file'**
  String get chooseFile;

  /// No description provided for @pasteText.
  ///
  /// In en, this message translates to:
  /// **'Paste text'**
  String get pasteText;

  /// No description provided for @pasteHint.
  ///
  /// In en, this message translates to:
  /// **'Paste the PGN here'**
  String get pasteHint;

  /// No description provided for @validateAndImport.
  ///
  /// In en, this message translates to:
  /// **'Validate and import'**
  String get validateAndImport;

  /// No description provided for @validateOnly.
  ///
  /// In en, this message translates to:
  /// **'Validate only'**
  String get validateOnly;

  /// No description provided for @copyPrompt.
  ///
  /// In en, this message translates to:
  /// **'Copy annotation prompt'**
  String get copyPrompt;

  /// No description provided for @promptCopied.
  ///
  /// In en, this message translates to:
  /// **'Annotation prompt copied'**
  String get promptCopied;

  /// No description provided for @chooseColourFirst.
  ///
  /// In en, this message translates to:
  /// **'Choose a colour first'**
  String get chooseColourFirst;

  /// No description provided for @errorNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get errorNameRequired;

  /// No description provided for @errorNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'At most 60 characters'**
  String get errorNameTooLong;

  /// No description provided for @warningNameExists.
  ///
  /// In en, this message translates to:
  /// **'A repertoire with this name already exists'**
  String get warningNameExists;

  /// No description provided for @errorColourRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose White or Black'**
  String get errorColourRequired;

  /// No description provided for @errorSourceRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose a file or paste a PGN'**
  String get errorSourceRequired;

  /// No description provided for @fileReadError.
  ///
  /// In en, this message translates to:
  /// **'Could not read the file: {error}'**
  String fileReadError(String error);

  /// No description provided for @stageReading.
  ///
  /// In en, this message translates to:
  /// **'Reading file'**
  String get stageReading;

  /// No description provided for @stageParsing.
  ///
  /// In en, this message translates to:
  /// **'Parsing'**
  String get stageParsing;

  /// No description provided for @stageBuildingLines.
  ///
  /// In en, this message translates to:
  /// **'Building lines'**
  String get stageBuildingLines;

  /// No description provided for @stageCheckingComments.
  ///
  /// In en, this message translates to:
  /// **'Checking comments'**
  String get stageCheckingComments;

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String importFailed(String error);

  /// No description provided for @importReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import report'**
  String get importReportTitle;

  /// No description provided for @reportGames.
  ///
  /// In en, this message translates to:
  /// **'Games merged'**
  String get reportGames;

  /// No description provided for @reportLines.
  ///
  /// In en, this message translates to:
  /// **'Lines'**
  String get reportLines;

  /// No description provided for @reportUserMoves.
  ///
  /// In en, this message translates to:
  /// **'Your moves'**
  String get reportUserMoves;

  /// No description provided for @reportOpponentMoves.
  ///
  /// In en, this message translates to:
  /// **'Opponent moves'**
  String get reportOpponentMoves;

  /// No description provided for @reportCommented.
  ///
  /// In en, this message translates to:
  /// **'Your moves with comments'**
  String get reportCommented;

  /// No description provided for @reportCommentedValue.
  ///
  /// In en, this message translates to:
  /// **'{count} ({percent} %)'**
  String reportCommentedValue(int count, int percent);

  /// No description provided for @reportDepth.
  ///
  /// In en, this message translates to:
  /// **'Deepest line'**
  String get reportDepth;

  /// No description provided for @reportDepthValue.
  ///
  /// In en, this message translates to:
  /// **'{plies} plies'**
  String reportDepthValue(int plies);

  /// No description provided for @reportErrors.
  ///
  /// In en, this message translates to:
  /// **'Errors ({count})'**
  String reportErrors(int count);

  /// No description provided for @reportWarnings.
  ///
  /// In en, this message translates to:
  /// **'Warnings ({count})'**
  String reportWarnings(int count);

  /// No description provided for @reportInfo.
  ///
  /// In en, this message translates to:
  /// **'Info ({count})'**
  String reportInfo(int count);

  /// No description provided for @importAction.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importAction;

  /// No description provided for @copyReport.
  ///
  /// In en, this message translates to:
  /// **'Copy report'**
  String get copyReport;

  /// No description provided for @reportCopied.
  ///
  /// In en, this message translates to:
  /// **'Report copied'**
  String get reportCopied;

  /// No description provided for @processedIn.
  ///
  /// In en, this message translates to:
  /// **'Processed in {ms} ms'**
  String processedIn(int ms);

  /// No description provided for @importBlocked.
  ///
  /// In en, this message translates to:
  /// **'Fix the errors, then validate again.'**
  String get importBlocked;

  /// No description provided for @positionPreview.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get positionPreview;

  /// No description provided for @diffTitle.
  ///
  /// In en, this message translates to:
  /// **'Changes'**
  String get diffTitle;

  /// No description provided for @diffUnchanged.
  ///
  /// In en, this message translates to:
  /// **'Unchanged lines (stats kept)'**
  String get diffUnchanged;

  /// No description provided for @diffExtended.
  ///
  /// In en, this message translates to:
  /// **'Extended lines (history carried over)'**
  String get diffExtended;

  /// No description provided for @diffNew.
  ///
  /// In en, this message translates to:
  /// **'New lines'**
  String get diffNew;

  /// No description provided for @diffRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed lines (stats archived, restored if the line comes back)'**
  String get diffRemoved;

  /// No description provided for @diffCommentChanges.
  ///
  /// In en, this message translates to:
  /// **'Your moves with changed comments'**
  String get diffCommentChanges;

  /// No description provided for @reimportTitle.
  ///
  /// In en, this message translates to:
  /// **'Re-import {name}'**
  String reimportTitle(String name);

  /// No description provided for @reimportColour.
  ///
  /// In en, this message translates to:
  /// **'Colour: {colour} (cannot change)'**
  String reimportColour(String colour);

  /// No description provided for @reimported.
  ///
  /// In en, this message translates to:
  /// **'Re-imported {name}'**
  String reimported(String name);

  /// No description provided for @detailAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get detailAccuracy;

  /// No description provided for @detailCoverage.
  ///
  /// In en, this message translates to:
  /// **'Coverage'**
  String get detailCoverage;

  /// No description provided for @detailCoverageValue.
  ///
  /// In en, this message translates to:
  /// **'{trained} of {total} lines trained'**
  String detailCoverageValue(int trained, int total);

  /// No description provided for @detailWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak lines'**
  String get detailWeak;

  /// No description provided for @detailDue.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get detailDue;

  /// No description provided for @detailNewToday.
  ///
  /// In en, this message translates to:
  /// **'New available today'**
  String get detailNewToday;

  /// No description provided for @train.
  ///
  /// In en, this message translates to:
  /// **'Train'**
  String get train;

  /// No description provided for @browse.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get browse;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats;

  /// No description provided for @settingsTraining.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get settingsTraining;

  /// No description provided for @settingsBoard.
  ///
  /// In en, this message translates to:
  /// **'Board and sound'**
  String get settingsBoard;

  /// No description provided for @settingsEngine.
  ///
  /// In en, this message translates to:
  /// **'Engine'**
  String get settingsEngine;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsSync.
  ///
  /// In en, this message translates to:
  /// **'Sync and backup'**
  String get settingsSync;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @themeLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeLabel;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version} ({build})'**
  String aboutVersion(String version, String build);

  /// No description provided for @aboutLicense.
  ///
  /// In en, this message translates to:
  /// **'Repertoire Trainer is free software licensed under the GNU General Public License, version 3 or later.'**
  String get aboutLicense;

  /// No description provided for @aboutStockfish.
  ///
  /// In en, this message translates to:
  /// **'Includes Stockfish {tag} (GPL-3.0).'**
  String aboutStockfish(String tag);

  /// No description provided for @aboutLicenses.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get aboutLicenses;

  /// No description provided for @aboutSource.
  ///
  /// In en, this message translates to:
  /// **'Source code'**
  String get aboutSource;

  /// No description provided for @aboutStockfishSource.
  ///
  /// In en, this message translates to:
  /// **'Stockfish source code'**
  String get aboutStockfishSource;

  /// No description provided for @diagnosticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics'**
  String get diagnosticsTitle;

  /// No description provided for @startupTimings.
  ///
  /// In en, this message translates to:
  /// **'Startup timings'**
  String get startupTimings;

  /// No description provided for @processToMain.
  ///
  /// In en, this message translates to:
  /// **'Process start → main'**
  String get processToMain;

  /// No description provided for @mainToRunApp.
  ///
  /// In en, this message translates to:
  /// **'main → runApp'**
  String get mainToRunApp;

  /// No description provided for @runAppToFirstFrame.
  ///
  /// In en, this message translates to:
  /// **'runApp → first frame'**
  String get runAppToFirstFrame;

  /// No description provided for @firstFrameToHome.
  ///
  /// In en, this message translates to:
  /// **'First frame → Home data'**
  String get firstFrameToHome;

  /// No description provided for @mainToHome.
  ///
  /// In en, this message translates to:
  /// **'main → Home data'**
  String get mainToHome;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'n/a'**
  String get notAvailable;

  /// No description provided for @framesTitle.
  ///
  /// In en, this message translates to:
  /// **'Frames'**
  String get framesTitle;

  /// No description provided for @framesCount.
  ///
  /// In en, this message translates to:
  /// **'Frames'**
  String get framesCount;

  /// No description provided for @framesJanky.
  ///
  /// In en, this message translates to:
  /// **'Frames over budget'**
  String get framesJanky;

  /// No description provided for @framesAverageBuild.
  ///
  /// In en, this message translates to:
  /// **'Average build'**
  String get framesAverageBuild;

  /// No description provided for @framesAverageRaster.
  ///
  /// In en, this message translates to:
  /// **'Average raster'**
  String get framesAverageRaster;

  /// No description provided for @framesWorst.
  ///
  /// In en, this message translates to:
  /// **'Worst frame'**
  String get framesWorst;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @msValue.
  ///
  /// In en, this message translates to:
  /// **'{ms} ms'**
  String msValue(String ms);

  /// No description provided for @noComment.
  ///
  /// In en, this message translates to:
  /// **'No comment for this move'**
  String get noComment;

  /// No description provided for @commentWhy.
  ///
  /// In en, this message translates to:
  /// **'Why'**
  String get commentWhy;

  /// No description provided for @commentPlan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get commentPlan;

  /// No description provided for @commentWatch.
  ///
  /// In en, this message translates to:
  /// **'Watch out'**
  String get commentWatch;

  /// No description provided for @commentAlternatives.
  ///
  /// In en, this message translates to:
  /// **'Alternatives'**
  String get commentAlternatives;

  /// No description provided for @showAlternatives.
  ///
  /// In en, this message translates to:
  /// **'Show alternatives'**
  String get showAlternatives;

  /// No description provided for @hideAlternatives.
  ///
  /// In en, this message translates to:
  /// **'Hide alternatives'**
  String get hideAlternatives;

  /// No description provided for @browseTitle.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get browseTitle;

  /// No description provided for @browseStart.
  ///
  /// In en, this message translates to:
  /// **'Start position'**
  String get browseStart;

  /// No description provided for @browseFirst.
  ///
  /// In en, this message translates to:
  /// **'First move'**
  String get browseFirst;

  /// No description provided for @browseBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get browseBack;

  /// No description provided for @browseForward.
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get browseForward;

  /// No description provided for @browseLast.
  ///
  /// In en, this message translates to:
  /// **'Last move'**
  String get browseLast;

  /// No description provided for @flipBoard.
  ///
  /// In en, this message translates to:
  /// **'Flip board'**
  String get flipBoard;

  /// No description provided for @chooseMove.
  ///
  /// In en, this message translates to:
  /// **'Choose a move'**
  String get chooseMove;

  /// No description provided for @backToRepertoire.
  ///
  /// In en, this message translates to:
  /// **'Back to repertoire'**
  String get backToRepertoire;

  /// No description provided for @exploring.
  ///
  /// In en, this message translates to:
  /// **'Exploring (not saved)'**
  String get exploring;

  /// No description provided for @opponentMoveNoComment.
  ///
  /// In en, this message translates to:
  /// **'Opponent move'**
  String get opponentMoveNoComment;

  /// No description provided for @boardSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Board and sound'**
  String get boardSettingsTitle;

  /// No description provided for @boardTheme.
  ///
  /// In en, this message translates to:
  /// **'Board theme'**
  String get boardTheme;

  /// No description provided for @pieceSet.
  ///
  /// In en, this message translates to:
  /// **'Piece set'**
  String get pieceSet;

  /// No description provided for @showCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Coordinates'**
  String get showCoordinates;

  /// No description provided for @showLegalMoves.
  ///
  /// In en, this message translates to:
  /// **'Legal move dots'**
  String get showLegalMoves;

  /// No description provided for @highlightLastMove.
  ///
  /// In en, this message translates to:
  /// **'Highlight last move'**
  String get highlightLastMove;

  /// No description provided for @animationSpeed.
  ///
  /// In en, this message translates to:
  /// **'Animation speed'**
  String get animationSpeed;

  /// No description provided for @animationSlow.
  ///
  /// In en, this message translates to:
  /// **'Slow'**
  String get animationSlow;

  /// No description provided for @animationNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get animationNormal;

  /// No description provided for @animationFast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get animationFast;

  /// No description provided for @animationOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get animationOff;

  /// No description provided for @soundsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Sounds'**
  String get soundsEnabled;

  /// No description provided for @soundVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get soundVolume;

  /// No description provided for @hapticsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Haptics'**
  String get hapticsEnabled;

  /// No description provided for @framesSlowBuilds.
  ///
  /// In en, this message translates to:
  /// **'Slow builds (UI thread)'**
  String get framesSlowBuilds;

  /// No description provided for @framesSlowRasters.
  ///
  /// In en, this message translates to:
  /// **'Slow rasters'**
  String get framesSlowRasters;

  /// No description provided for @analysisToggle.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get analysisToggle;

  /// No description provided for @engineUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Engine unavailable'**
  String get engineUnavailable;

  /// No description provided for @analysing.
  ///
  /// In en, this message translates to:
  /// **'Analysing…'**
  String get analysing;

  /// No description provided for @analysisDepth.
  ///
  /// In en, this message translates to:
  /// **'Depth {depth}'**
  String analysisDepth(int depth);

  /// No description provided for @engineThreadsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 thread} other{{count} threads}}'**
  String engineThreadsCount(int count);

  /// No description provided for @engineMnps.
  ///
  /// In en, this message translates to:
  /// **'{value} Mnps'**
  String engineMnps(String value);

  /// No description provided for @engineReady.
  ///
  /// In en, this message translates to:
  /// **'ready'**
  String get engineReady;

  /// No description provided for @engineNotRunning.
  ///
  /// In en, this message translates to:
  /// **'not running'**
  String get engineNotRunning;

  /// No description provided for @engineStarting.
  ///
  /// In en, this message translates to:
  /// **'starting…'**
  String get engineStarting;

  /// No description provided for @engineError.
  ///
  /// In en, this message translates to:
  /// **'error ({message}); restarts on the next search'**
  String engineError(String message);

  /// No description provided for @engineUnavailableStatus.
  ///
  /// In en, this message translates to:
  /// **'unavailable ({message}). Tap Restart engine.'**
  String engineUnavailableStatus(String message);

  /// No description provided for @comparableThreshold.
  ///
  /// In en, this message translates to:
  /// **'Comparable threshold'**
  String get comparableThreshold;

  /// No description provided for @pawnsValue.
  ///
  /// In en, this message translates to:
  /// **'{value} pawns'**
  String pawnsValue(String value);

  /// No description provided for @checkSearchTime.
  ///
  /// In en, this message translates to:
  /// **'Check search time'**
  String get checkSearchTime;

  /// No description provided for @secondsValue.
  ///
  /// In en, this message translates to:
  /// **'{value} s'**
  String secondsValue(String value);

  /// No description provided for @engineThreads.
  ///
  /// In en, this message translates to:
  /// **'Threads'**
  String get engineThreads;

  /// No description provided for @engineHash.
  ///
  /// In en, this message translates to:
  /// **'Hash'**
  String get engineHash;

  /// No description provided for @autoValue.
  ///
  /// In en, this message translates to:
  /// **'Auto ({value})'**
  String autoValue(String value);

  /// No description provided for @playOnStrength.
  ///
  /// In en, this message translates to:
  /// **'Play-on strength'**
  String get playOnStrength;

  /// No description provided for @fullStrength.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get fullStrength;

  /// No description provided for @calibration.
  ///
  /// In en, this message translates to:
  /// **'Calibration'**
  String get calibration;

  /// No description provided for @notCalibrated.
  ///
  /// In en, this message translates to:
  /// **'Not calibrated yet'**
  String get notCalibrated;

  /// No description provided for @calibrationValue.
  ///
  /// In en, this message translates to:
  /// **'{mnps} Mnps · depth {depth} in 1 s'**
  String calibrationValue(String mnps, int depth);

  /// No description provided for @runCalibration.
  ///
  /// In en, this message translates to:
  /// **'Run calibration'**
  String get runCalibration;

  /// No description provided for @slowDeviceNote.
  ///
  /// In en, this message translates to:
  /// **'This device usually needs more than 1 s per check; banners may appear a little later.'**
  String get slowDeviceNote;

  /// No description provided for @restartEngine.
  ///
  /// In en, this message translates to:
  /// **'Restart engine'**
  String get restartEngine;

  /// No description provided for @engineTitle.
  ///
  /// In en, this message translates to:
  /// **'Engine'**
  String get engineTitle;

  /// No description provided for @engineBinary.
  ///
  /// In en, this message translates to:
  /// **'Binary'**
  String get engineBinary;

  /// No description provided for @engineMissing.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get engineMissing;

  /// No description provided for @engineVariant.
  ///
  /// In en, this message translates to:
  /// **'Variant'**
  String get engineVariant;

  /// No description provided for @engineVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get engineVersion;

  /// No description provided for @engineState.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get engineState;

  /// No description provided for @calibrationNps.
  ///
  /// In en, this message translates to:
  /// **'Calibration nps'**
  String get calibrationNps;

  /// No description provided for @calibrationDepth2s.
  ///
  /// In en, this message translates to:
  /// **'Depth in 2 s'**
  String get calibrationDepth2s;

  /// No description provided for @calibrationDepth1s.
  ///
  /// In en, this message translates to:
  /// **'Median depth in 1 s'**
  String get calibrationDepth1s;

  /// No description provided for @engineRecentJobs.
  ///
  /// In en, this message translates to:
  /// **'Last jobs'**
  String get engineRecentJobs;

  /// No description provided for @trainTitle.
  ///
  /// In en, this message translates to:
  /// **'Train'**
  String get trainTitle;

  /// No description provided for @modeRandom.
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get modeRandom;

  /// No description provided for @trainingSettings.
  ///
  /// In en, this message translates to:
  /// **'Training settings'**
  String get trainingSettings;

  /// No description provided for @noTrainableLines.
  ///
  /// In en, this message translates to:
  /// **'This repertoire has no line with moves of your colour.'**
  String get noTrainableLines;

  /// No description provided for @yourMove.
  ///
  /// In en, this message translates to:
  /// **'Your move'**
  String get yourMove;

  /// No description provided for @opponentToMove.
  ///
  /// In en, this message translates to:
  /// **'Opponent to move'**
  String get opponentToMove;

  /// No description provided for @skippedToMove.
  ///
  /// In en, this message translates to:
  /// **'Skipped to move {move}'**
  String skippedToMove(int move);

  /// No description provided for @comparableBanner.
  ///
  /// In en, this message translates to:
  /// **'That is not the move in your repertoire, but it is a comparable move.'**
  String get comparableBanner;

  /// No description provided for @notRepertoireMove.
  ///
  /// In en, this message translates to:
  /// **'Not your repertoire move'**
  String get notRepertoireMove;

  /// No description provided for @bannerWithMove.
  ///
  /// In en, this message translates to:
  /// **'{move}: {text}'**
  String bannerWithMove(String move, String text);

  /// No description provided for @runAccuracy.
  ///
  /// In en, this message translates to:
  /// **'{credit}/{graded} · {percent} %'**
  String runAccuracy(String credit, int graded, int percent);

  /// No description provided for @hint.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get hint;

  /// No description provided for @showMove.
  ///
  /// In en, this message translates to:
  /// **'Show move'**
  String get showMove;

  /// No description provided for @moveProgress.
  ///
  /// In en, this message translates to:
  /// **'Move {current} of {total}'**
  String moveProgress(int current, int total);

  /// No description provided for @skipLine.
  ///
  /// In en, this message translates to:
  /// **'Skip line'**
  String get skipLine;

  /// No description provided for @nextLine.
  ///
  /// In en, this message translates to:
  /// **'Next line'**
  String get nextLine;

  /// No description provided for @sessionSummary.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get sessionSummary;

  /// No description provided for @linesCompleted.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 line completed} other{{count} lines completed}}'**
  String linesCompleted(int count);

  /// No description provided for @sessionAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy {percent} %'**
  String sessionAccuracy(int percent);

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @wrongMoveBehaviour.
  ///
  /// In en, this message translates to:
  /// **'Wrong move behaviour'**
  String get wrongMoveBehaviour;

  /// No description provided for @wrongMoveRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get wrongMoveRetry;

  /// No description provided for @wrongMoveRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart line'**
  String get wrongMoveRestart;

  /// No description provided for @startFrom.
  ///
  /// In en, this message translates to:
  /// **'Start from'**
  String get startFrom;

  /// No description provided for @startFromMove1.
  ///
  /// In en, this message translates to:
  /// **'Move 1'**
  String get startFromMove1;

  /// No description provided for @startFromBranch.
  ///
  /// In en, this message translates to:
  /// **'Branch point'**
  String get startFromBranch;

  /// No description provided for @autoAdvanceDelay.
  ///
  /// In en, this message translates to:
  /// **'Auto-advance delay'**
  String get autoAdvanceDelay;

  /// No description provided for @opponentDelay.
  ///
  /// In en, this message translates to:
  /// **'Opponent move delay'**
  String get opponentDelay;

  /// No description provided for @showCommentsInDrills.
  ///
  /// In en, this message translates to:
  /// **'Show comments during drills'**
  String get showCommentsInDrills;

  /// No description provided for @showCommentArrows.
  ///
  /// In en, this message translates to:
  /// **'Show comment arrows'**
  String get showCommentArrows;

  /// No description provided for @drillEvalBar.
  ///
  /// In en, this message translates to:
  /// **'Eval bar in drills'**
  String get drillEvalBar;

  /// No description provided for @toggleEvalBar.
  ///
  /// In en, this message translates to:
  /// **'Toggle eval bar'**
  String get toggleEvalBar;

  /// No description provided for @drillLatency.
  ///
  /// In en, this message translates to:
  /// **'Drill latency'**
  String get drillLatency;

  /// No description provided for @latencyP50.
  ///
  /// In en, this message translates to:
  /// **'Median'**
  String get latencyP50;

  /// No description provided for @latencyP95.
  ///
  /// In en, this message translates to:
  /// **'95th percentile'**
  String get latencyP95;

  /// No description provided for @latencySamples.
  ///
  /// In en, this message translates to:
  /// **'Samples'**
  String get latencySamples;

  /// No description provided for @modeWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak lines'**
  String get modeWeak;

  /// No description provided for @modeWeakCount.
  ///
  /// In en, this message translates to:
  /// **'Weak {count}'**
  String modeWeakCount(int count);

  /// No description provided for @modeSrs.
  ///
  /// In en, this message translates to:
  /// **'Spaced repetition'**
  String get modeSrs;

  /// No description provided for @modeSrsLeft.
  ///
  /// In en, this message translates to:
  /// **'SRS {count} left'**
  String modeSrsLeft(int count);

  /// No description provided for @modeSingle.
  ///
  /// In en, this message translates to:
  /// **'Single line'**
  String get modeSingle;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @noWeakLines.
  ///
  /// In en, this message translates to:
  /// **'No weak lines. Nice.'**
  String get noWeakLines;

  /// No description provided for @srsLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Daily review limit reached.'**
  String get srsLimitReached;

  /// No description provided for @allCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'All caught up.'**
  String get allCaughtUp;

  /// No description provided for @allCaughtUpNext.
  ///
  /// In en, this message translates to:
  /// **'All caught up. Next review: {date} ({count, plural, =1{1 line} other{{count} lines}})'**
  String allCaughtUpNext(String date, int count);

  /// No description provided for @trainWeakLines.
  ///
  /// In en, this message translates to:
  /// **'Train weak lines'**
  String get trainWeakLines;

  /// No description provided for @lineAccuracyChange.
  ///
  /// In en, this message translates to:
  /// **'Line accuracy (last 10): {before} → {after}'**
  String lineAccuracyChange(String before, String after);

  /// No description provided for @enteredWeakPool.
  ///
  /// In en, this message translates to:
  /// **'Entered weak pool'**
  String get enteredWeakPool;

  /// No description provided for @leftWeakPool.
  ///
  /// In en, this message translates to:
  /// **'Left weak pool'**
  String get leftWeakPool;

  /// No description provided for @srsNextDue.
  ///
  /// In en, this message translates to:
  /// **'Next review: {date}'**
  String srsNextDue(String date);

  /// No description provided for @retryThisLine.
  ///
  /// In en, this message translates to:
  /// **'Retry this line'**
  String get retryThisLine;

  /// No description provided for @browseThisLine.
  ///
  /// In en, this message translates to:
  /// **'Browse this line'**
  String get browseThisLine;

  /// No description provided for @youPlayed.
  ///
  /// In en, this message translates to:
  /// **'You played {move}'**
  String youPlayed(String move);

  /// No description provided for @hintUsed.
  ///
  /// In en, this message translates to:
  /// **'Hint used'**
  String get hintUsed;

  /// No description provided for @modeRandomHint.
  ///
  /// In en, this message translates to:
  /// **'All lines, weighted towards weak and stale ones'**
  String get modeRandomHint;

  /// No description provided for @weakPoolSize.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 line in the pool} other{{count} lines in the pool}}'**
  String weakPoolSize(int count);

  /// No description provided for @weakPoolEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'No weak lines yet: lines enter the pool below the accuracy threshold.'**
  String get weakPoolEmptyHint;

  /// No description provided for @srsCounts.
  ///
  /// In en, this message translates to:
  /// **'{due} due, {fresh} new available'**
  String srsCounts(int due, int fresh);

  /// No description provided for @opponentDeviations.
  ///
  /// In en, this message translates to:
  /// **'Opponent deviations'**
  String get opponentDeviations;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @continueTraining.
  ///
  /// In en, this message translates to:
  /// **'Continue: {name} · {mode}'**
  String continueTraining(String name, String mode);

  /// No description provided for @showLineSummary.
  ///
  /// In en, this message translates to:
  /// **'Show line summary'**
  String get showLineSummary;

  /// No description provided for @weakEnterBelow.
  ///
  /// In en, this message translates to:
  /// **'Weak pool: enter below accuracy'**
  String get weakEnterBelow;

  /// No description provided for @weakExitAfter.
  ///
  /// In en, this message translates to:
  /// **'Weak pool: leave after clean runs'**
  String get weakExitAfter;

  /// No description provided for @srsNewPerDay.
  ///
  /// In en, this message translates to:
  /// **'SRS: new lines per day'**
  String get srsNewPerDay;

  /// No description provided for @srsMaxReviews.
  ///
  /// In en, this message translates to:
  /// **'SRS: max reviews per day'**
  String get srsMaxReviews;

  /// No description provided for @unlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get unlimited;

  /// No description provided for @dayStartsAt.
  ///
  /// In en, this message translates to:
  /// **'Day starts at'**
  String get dayStartsAt;

  /// No description provided for @percentValue.
  ///
  /// In en, this message translates to:
  /// **'{value} %'**
  String percentValue(int value);

  /// No description provided for @deviationsThisSession.
  ///
  /// In en, this message translates to:
  /// **'This session only'**
  String get deviationsThisSession;

  /// No description provided for @deviationChance.
  ///
  /// In en, this message translates to:
  /// **'Deviation chance per line'**
  String get deviationChance;

  /// No description provided for @deviationTiming.
  ///
  /// In en, this message translates to:
  /// **'Deviation timing'**
  String get deviationTiming;

  /// No description provided for @timingEndOfLine.
  ///
  /// In en, this message translates to:
  /// **'End of line'**
  String get timingEndOfLine;

  /// No description provided for @timingAnywhere.
  ///
  /// In en, this message translates to:
  /// **'Anywhere in the line'**
  String get timingAnywhere;

  /// No description provided for @checkingReply.
  ///
  /// In en, this message translates to:
  /// **'Checking your reply…'**
  String get checkingReply;

  /// No description provided for @goodReply.
  ///
  /// In en, this message translates to:
  /// **'Good reply'**
  String get goodReply;

  /// No description provided for @inaccurate.
  ///
  /// In en, this message translates to:
  /// **'Inaccurate'**
  String get inaccurate;

  /// No description provided for @inaccurateBestWas.
  ///
  /// In en, this message translates to:
  /// **'Inaccurate. Best was {san}'**
  String inaccurateBestWas(String san);

  /// No description provided for @deviationMidLine.
  ///
  /// In en, this message translates to:
  /// **'Opponent left your repertoire. Find a good reply.'**
  String get deviationMidLine;

  /// No description provided for @deviationEndPlaysOn.
  ///
  /// In en, this message translates to:
  /// **'Your repertoire ends here. The opponent plays on: find a good reply.'**
  String get deviationEndPlaysOn;

  /// No description provided for @deviationEndFindMove.
  ///
  /// In en, this message translates to:
  /// **'Your repertoire ends here. Find a good move.'**
  String get deviationEndFindMove;

  /// No description provided for @hintFailsReply.
  ///
  /// In en, this message translates to:
  /// **'Hint used: this reply counts as missed.'**
  String get hintFailsReply;

  /// No description provided for @playOn.
  ///
  /// In en, this message translates to:
  /// **'Play on'**
  String get playOn;

  /// No description provided for @playOnTitle.
  ///
  /// In en, this message translates to:
  /// **'Play on · {strength}'**
  String playOnTitle(String strength);

  /// No description provided for @strengthClub.
  ///
  /// In en, this message translates to:
  /// **'Club 1500'**
  String get strengthClub;

  /// No description provided for @strengthStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong 2000'**
  String get strengthStrong;

  /// No description provided for @strengthExpert.
  ///
  /// In en, this message translates to:
  /// **'Expert 2500'**
  String get strengthExpert;

  /// No description provided for @backToTraining.
  ///
  /// In en, this message translates to:
  /// **'Back to training'**
  String get backToTraining;

  /// No description provided for @takeBack.
  ///
  /// In en, this message translates to:
  /// **'Take back'**
  String get takeBack;

  /// No description provided for @analyse.
  ///
  /// In en, this message translates to:
  /// **'Analyse'**
  String get analyse;

  /// No description provided for @engineThinking.
  ///
  /// In en, this message translates to:
  /// **'Engine thinking…'**
  String get engineThinking;

  /// No description provided for @resultUserMates.
  ///
  /// In en, this message translates to:
  /// **'Checkmate. You win.'**
  String get resultUserMates;

  /// No description provided for @resultEngineMates.
  ///
  /// In en, this message translates to:
  /// **'Checkmate. The engine wins.'**
  String get resultEngineMates;

  /// No description provided for @resultStalemate.
  ///
  /// In en, this message translates to:
  /// **'Stalemate. Draw.'**
  String get resultStalemate;

  /// No description provided for @resultThreefold.
  ///
  /// In en, this message translates to:
  /// **'Threefold repetition. Draw.'**
  String get resultThreefold;

  /// No description provided for @resultFiftyMoves.
  ///
  /// In en, this message translates to:
  /// **'50-move rule. Draw.'**
  String get resultFiftyMoves;

  /// No description provided for @resultInsufficient.
  ///
  /// In en, this message translates to:
  /// **'Insufficient material. Draw.'**
  String get resultInsufficient;

  /// No description provided for @deviationJobs.
  ///
  /// In en, this message translates to:
  /// **'Deviation candidates'**
  String get deviationJobs;

  /// No description provided for @deviationReadyRate.
  ///
  /// In en, this message translates to:
  /// **'Ready when needed'**
  String get deviationReadyRate;

  /// No description provided for @deviationReadyValue.
  ///
  /// In en, this message translates to:
  /// **'{percent} % of {count}'**
  String deviationReadyValue(int percent, int count);

  /// No description provided for @deviationJobCount.
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get deviationJobCount;

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1-day streak} other{{count}-day streak}}'**
  String streakDays(int count);

  /// No description provided for @streakBest.
  ///
  /// In en, this message translates to:
  /// **'Best: {count}'**
  String streakBest(int count);

  /// No description provided for @streakDone.
  ///
  /// In en, this message translates to:
  /// **'Done today'**
  String get streakDone;

  /// No description provided for @streakKeep.
  ///
  /// In en, this message translates to:
  /// **'Train one line to keep your streak'**
  String get streakKeep;

  /// No description provided for @sessionStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak: {count, plural, =1{1 day} other{{count} days}}{done, select, true{, today done} other{}}'**
  String sessionStreak(int count, String done);

  /// No description provided for @statsOf.
  ///
  /// In en, this message translates to:
  /// **'Stats · {name}'**
  String statsOf(String name);

  /// No description provided for @statsAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get statsAccuracy;

  /// No description provided for @statsCoverage.
  ///
  /// In en, this message translates to:
  /// **'Coverage'**
  String get statsCoverage;

  /// No description provided for @statsWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak lines'**
  String get statsWeak;

  /// No description provided for @statsDue.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get statsDue;

  /// No description provided for @statsRuns.
  ///
  /// In en, this message translates to:
  /// **'Runs'**
  String get statsRuns;

  /// No description provided for @statsStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get statsStreak;

  /// No description provided for @accuracyOverTime.
  ///
  /// In en, this message translates to:
  /// **'Accuracy over time'**
  String get accuracyOverTime;

  /// No description provided for @range30.
  ///
  /// In en, this message translates to:
  /// **'30 d'**
  String get range30;

  /// No description provided for @range90.
  ///
  /// In en, this message translates to:
  /// **'90 d'**
  String get range90;

  /// No description provided for @rangeAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get rangeAll;

  /// No description provided for @noRunsYet.
  ///
  /// In en, this message translates to:
  /// **'No runs yet'**
  String get noRunsYet;

  /// No description provided for @worstLines.
  ///
  /// In en, this message translates to:
  /// **'Worst lines'**
  String get worstLines;

  /// No description provided for @showAll.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get showAll;

  /// No description provided for @mostMissedMoves.
  ///
  /// In en, this message translates to:
  /// **'Most missed moves'**
  String get mostMissedMoves;

  /// No description provided for @noMissedMoves.
  ///
  /// In en, this message translates to:
  /// **'No move missed yet (at least 3 attempts).'**
  String get noMissedMoves;

  /// No description provided for @missedOf.
  ///
  /// In en, this message translates to:
  /// **'{move} (missed {misses} of {attempts})'**
  String missedOf(String move, int misses, int attempts);

  /// No description provided for @deviationReplies.
  ///
  /// In en, this message translates to:
  /// **'Deviation replies'**
  String get deviationReplies;

  /// No description provided for @deviationRepliesSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 reply} other{{count} replies}} · {percent} % good'**
  String deviationRepliesSummary(int count, int percent);

  /// No description provided for @allLines.
  ///
  /// In en, this message translates to:
  /// **'All lines'**
  String get allLines;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @sortAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get sortAccuracy;

  /// No description provided for @sortLastPlayed.
  ///
  /// In en, this message translates to:
  /// **'Last played'**
  String get sortLastPlayed;

  /// No description provided for @sortRuns.
  ///
  /// In en, this message translates to:
  /// **'Runs'**
  String get sortRuns;

  /// No description provided for @sortOrder.
  ///
  /// In en, this message translates to:
  /// **'Line order'**
  String get sortOrder;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak only'**
  String get filterWeak;

  /// No description provided for @filterUntrained.
  ///
  /// In en, this message translates to:
  /// **'Untrained'**
  String get filterUntrained;

  /// No description provided for @filterArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get filterArchived;

  /// No description provided for @lineRunsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 run} other{{count} runs}}'**
  String lineRunsCount(int count);

  /// No description provided for @lineDetail.
  ///
  /// In en, this message translates to:
  /// **'Line'**
  String get lineDetail;

  /// No description provided for @notInCurrentPgn.
  ///
  /// In en, this message translates to:
  /// **'Not in current PGN'**
  String get notInCurrentPgn;

  /// No description provided for @weakPool.
  ///
  /// In en, this message translates to:
  /// **'Weak pool'**
  String get weakPool;

  /// No description provided for @notWeak.
  ///
  /// In en, this message translates to:
  /// **'Not weak'**
  String get notWeak;

  /// No description provided for @weakCleanRuns.
  ///
  /// In en, this message translates to:
  /// **'In pool · clean runs {done} of {needed}'**
  String weakCleanRuns(int done, int needed);

  /// No description provided for @srsState.
  ///
  /// In en, this message translates to:
  /// **'Spaced repetition'**
  String get srsState;

  /// No description provided for @srsNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get srsNew;

  /// No description provided for @srsStateValue.
  ///
  /// In en, this message translates to:
  /// **'Due {date} · every {days} d · ease {ease}'**
  String srsStateValue(String date, int days, String ease);

  /// No description provided for @drillThisLine.
  ///
  /// In en, this message translates to:
  /// **'Drill this line'**
  String get drillThisLine;

  /// No description provided for @moveErrors.
  ///
  /// In en, this message translates to:
  /// **'Errors per move'**
  String get moveErrors;

  /// No description provided for @missedCount.
  ///
  /// In en, this message translates to:
  /// **'missed {misses} of {attempts}'**
  String missedCount(int misses, int attempts);

  /// No description provided for @runHistory.
  ///
  /// In en, this message translates to:
  /// **'Run history'**
  String get runHistory;

  /// No description provided for @abandoned.
  ///
  /// In en, this message translates to:
  /// **'abandoned'**
  String get abandoned;

  /// No description provided for @syncTitle.
  ///
  /// In en, this message translates to:
  /// **'Google Drive sync'**
  String get syncTitle;

  /// No description provided for @backupTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backupTitle;

  /// No description provided for @exportBackup.
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get exportBackup;

  /// No description provided for @exportBackupHint.
  ///
  /// In en, this message translates to:
  /// **'Repertoires, training history and settings in one file'**
  String get exportBackupHint;

  /// No description provided for @importBackup.
  ///
  /// In en, this message translates to:
  /// **'Import backup'**
  String get importBackup;

  /// No description provided for @importBackupHint.
  ///
  /// In en, this message translates to:
  /// **'Merge a backup file into this device, or replace everything'**
  String get importBackupHint;

  /// No description provided for @backupExporting.
  ///
  /// In en, this message translates to:
  /// **'Preparing the backup…'**
  String get backupExporting;

  /// No description provided for @backupReading.
  ///
  /// In en, this message translates to:
  /// **'Reading the backup…'**
  String get backupReading;

  /// No description provided for @backupImporting.
  ///
  /// In en, this message translates to:
  /// **'Importing…'**
  String get backupImporting;

  /// No description provided for @backupSaved.
  ///
  /// In en, this message translates to:
  /// **'Backup saved: {where}'**
  String backupSaved(String where);

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup failed: {error}'**
  String backupFailed(String error);

  /// No description provided for @backupNewer.
  ///
  /// In en, this message translates to:
  /// **'This backup is from a newer app version. Update this device first.'**
  String get backupNewer;

  /// No description provided for @backupInvalid.
  ///
  /// In en, this message translates to:
  /// **'Not a Repertoire Trainer backup.'**
  String get backupInvalid;

  /// No description provided for @backupContents.
  ///
  /// In en, this message translates to:
  /// **'{repertoires, plural, =1{1 repertoire} other{{repertoires} repertoires}}, {runs, plural, =1{1 run} other{{runs} runs}}, exported {date}'**
  String backupContents(int repertoires, int runs, String date);

  /// No description provided for @importMerge.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get importMerge;

  /// No description provided for @importMergeHint.
  ///
  /// In en, this message translates to:
  /// **'Keeps everything on this device; newer repertoire changes win, all runs are kept.'**
  String get importMergeHint;

  /// No description provided for @replaceAll.
  ///
  /// In en, this message translates to:
  /// **'Replace all'**
  String get replaceAll;

  /// No description provided for @importReplaceHint.
  ///
  /// In en, this message translates to:
  /// **'Deletes this device\'s repertoires and runs first.'**
  String get importReplaceHint;

  /// No description provided for @restoreSettings.
  ///
  /// In en, this message translates to:
  /// **'Also restore settings'**
  String get restoreSettings;

  /// No description provided for @replaceAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace all?'**
  String get replaceAllTitle;

  /// No description provided for @replaceAllBody.
  ///
  /// In en, this message translates to:
  /// **'This deletes {repertoires, plural, =1{1 repertoire} other{{repertoires} repertoires}} and {runs, plural, =1{1 run} other{{runs} runs}} on this device before importing.'**
  String replaceAllBody(int repertoires, int runs);

  /// No description provided for @backupImported.
  ///
  /// In en, this message translates to:
  /// **'Backup imported: {repertoires, plural, =1{1 repertoire} other{{repertoires} repertoires}} updated, {runs, plural, =1{1 run} other{{runs} runs}} added.'**
  String backupImported(int repertoires, int runs);

  /// No description provided for @updatedFromOtherDevice.
  ///
  /// In en, this message translates to:
  /// **'{name} was updated from another device.'**
  String updatedFromOtherDevice(String name);

  /// No description provided for @deletedOnOtherDevice.
  ///
  /// In en, this message translates to:
  /// **'This repertoire was deleted on another device.'**
  String get deletedOnOtherDevice;

  /// No description provided for @syncNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Sync is not configured in this build.'**
  String get syncNotConfigured;

  /// No description provided for @syncToggle.
  ///
  /// In en, this message translates to:
  /// **'Sync with Google Drive'**
  String get syncToggle;

  /// No description provided for @syncOffHint.
  ///
  /// In en, this message translates to:
  /// **'Keeps repertoires and training history the same on your phone and computer.'**
  String get syncOffHint;

  /// No description provided for @syncSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get syncSignedIn;

  /// No description provided for @syncSignedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {account}'**
  String syncSignedInAs(String account);

  /// No description provided for @syncNever.
  ///
  /// In en, this message translates to:
  /// **'never'**
  String get syncNever;

  /// No description provided for @syncLast.
  ///
  /// In en, this message translates to:
  /// **'Last sync: {when}'**
  String syncLast(String when);

  /// No description provided for @syncRunning.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get syncRunning;

  /// No description provided for @syncOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline, will retry'**
  String get syncOffline;

  /// No description provided for @syncSignInAgain.
  ///
  /// In en, this message translates to:
  /// **'Sign in again to keep syncing.'**
  String get syncSignInAgain;

  /// No description provided for @syncError.
  ///
  /// In en, this message translates to:
  /// **'Sync failed: {message}'**
  String syncError(String message);

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed: {error}'**
  String syncFailed(String error);

  /// No description provided for @syncNewerDevice.
  ///
  /// In en, this message translates to:
  /// **'Another device uses a newer app version. Update this device.'**
  String get syncNewerDevice;

  /// No description provided for @syncCorruptFile.
  ///
  /// In en, this message translates to:
  /// **'A file from another device could not be read; it was skipped.'**
  String get syncCorruptFile;

  /// No description provided for @signInAgain.
  ///
  /// In en, this message translates to:
  /// **'Sign in again'**
  String get signInAgain;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNow;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @deleteCloudData.
  ///
  /// In en, this message translates to:
  /// **'Delete cloud data'**
  String get deleteCloudData;

  /// No description provided for @deleteCloudTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete cloud data?'**
  String get deleteCloudTitle;

  /// No description provided for @deleteCloudBody.
  ///
  /// In en, this message translates to:
  /// **'Deletes the sync files of all your devices from Google Drive. Data on this device stays.'**
  String get deleteCloudBody;

  /// No description provided for @cloudDeleted.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 file deleted} other{{count} files deleted}}'**
  String cloudDeleted(int count);

  /// No description provided for @syncHelp.
  ///
  /// In en, this message translates to:
  /// **'Sync uses a hidden app folder in your Google Drive. A device with a wrong clock can win or lose a rename or re-import; training history is never lost.'**
  String get syncHelp;

  /// No description provided for @replaceSyncWarning.
  ///
  /// In en, this message translates to:
  /// **'Sync is on: the next sync brings back data from your other devices unless you also delete the cloud data.'**
  String get replaceSyncWarning;

  /// No description provided for @deviceIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Device id'**
  String get deviceIdLabel;

  /// No description provided for @syncPhaseLabel.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get syncPhaseLabel;

  /// No description provided for @syncMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get syncMessageLabel;

  /// No description provided for @listDriveFiles.
  ///
  /// In en, this message translates to:
  /// **'List Drive files'**
  String get listDriveFiles;

  /// No description provided for @openFileTitle.
  ///
  /// In en, this message translates to:
  /// **'Open {name}'**
  String openFileTitle(String name);

  /// No description provided for @reimportInto.
  ///
  /// In en, this message translates to:
  /// **'Re-import into {name}'**
  String reimportInto(String name);

  /// No description provided for @shortcutList.
  ///
  /// In en, this message translates to:
  /// **'Keyboard shortcuts'**
  String get shortcutList;

  /// No description provided for @shortcutsAnywhere.
  ///
  /// In en, this message translates to:
  /// **'Anywhere'**
  String get shortcutsAnywhere;

  /// No description provided for @shortcutsDrill.
  ///
  /// In en, this message translates to:
  /// **'Drill'**
  String get shortcutsDrill;

  /// No description provided for @shortcutsBrowse.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get shortcutsBrowse;

  /// No description provided for @shortcutLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave the screen'**
  String get shortcutLeave;

  /// No description provided for @shortcutHint.
  ///
  /// In en, this message translates to:
  /// **'Hint, then show the move'**
  String get shortcutHint;

  /// No description provided for @shortcutBackForward.
  ///
  /// In en, this message translates to:
  /// **'Back / forward one move'**
  String get shortcutBackForward;

  /// No description provided for @shortcutForward.
  ///
  /// In en, this message translates to:
  /// **'Forward (or the chooser at a fork)'**
  String get shortcutForward;

  /// No description provided for @shortcutStartEnd.
  ///
  /// In en, this message translates to:
  /// **'Start / end of the line'**
  String get shortcutStartEnd;

  /// No description provided for @shortcutSiblings.
  ///
  /// In en, this message translates to:
  /// **'Previous / next sibling move'**
  String get shortcutSiblings;

  /// No description provided for @logsTitle.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get logsTitle;

  /// No description provided for @exportLogs.
  ///
  /// In en, this message translates to:
  /// **'Export logs'**
  String get exportLogs;

  /// No description provided for @logsExported.
  ///
  /// In en, this message translates to:
  /// **'Logs saved'**
  String get logsExported;

  /// No description provided for @logsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No log files on this device'**
  String get logsUnavailable;

  /// No description provided for @logsExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the logs: {error}'**
  String logsExportFailed(String error);

  /// No description provided for @showVariations.
  ///
  /// In en, this message translates to:
  /// **'Show variations'**
  String get showVariations;

  /// No description provided for @hideVariations.
  ///
  /// In en, this message translates to:
  /// **'Hide variations'**
  String get hideVariations;

  /// No description provided for @framesBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget (display refresh rate)'**
  String get framesBudget;

  /// No description provided for @framesOverBudget.
  ///
  /// In en, this message translates to:
  /// **'Over budget'**
  String get framesOverBudget;

  /// No description provided for @percentDecimal.
  ///
  /// In en, this message translates to:
  /// **'{value} %'**
  String percentDecimal(String value);

  /// No description provided for @framesWorstRaster.
  ///
  /// In en, this message translates to:
  /// **'Worst raster'**
  String get framesWorstRaster;

  /// No description provided for @databaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Database'**
  String get databaseTitle;

  /// No description provided for @databaseFileSize.
  ///
  /// In en, this message translates to:
  /// **'File size'**
  String get databaseFileSize;

  /// No description provided for @databaseLastDerivation.
  ///
  /// In en, this message translates to:
  /// **'Last derivation'**
  String get databaseLastDerivation;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @importBenchmark.
  ///
  /// In en, this message translates to:
  /// **'Import benchmark'**
  String get importBenchmark;

  /// No description provided for @importBenchmarkHint.
  ///
  /// In en, this message translates to:
  /// **'Imports a 1,000-line synthetic PGN into a temporary repertoire, then deletes it'**
  String get importBenchmarkHint;

  /// No description provided for @importBenchmarkRunning.
  ///
  /// In en, this message translates to:
  /// **'Running…'**
  String get importBenchmarkRunning;

  /// No description provided for @importBenchmarkResult.
  ///
  /// In en, this message translates to:
  /// **'{lines} lines: {total} ms (import {import} ms, store {store} ms)'**
  String importBenchmarkResult(int lines, int total, int import, int store);

  /// No description provided for @gameReview.
  ///
  /// In en, this message translates to:
  /// **'Game Review'**
  String get gameReview;

  /// No description provided for @chessComUsername.
  ///
  /// In en, this message translates to:
  /// **'chess.com username'**
  String get chessComUsername;

  /// No description provided for @fetchGames.
  ///
  /// In en, this message translates to:
  /// **'Fetch games'**
  String get fetchGames;

  /// No description provided for @needsInternet.
  ///
  /// In en, this message translates to:
  /// **'Needs an internet connection'**
  String get needsInternet;

  /// No description provided for @gamesOffline.
  ///
  /// In en, this message translates to:
  /// **'You are offline. Fetching games needs internet; saved games still open.'**
  String get gamesOffline;

  /// No description provided for @checkConnection.
  ///
  /// In en, this message translates to:
  /// **'Check again'**
  String get checkConnection;

  /// No description provided for @archiveDelayNote.
  ///
  /// In en, this message translates to:
  /// **'chess.com updates its archives with a delay, so a game you just finished may not show yet.'**
  String get archiveDelayNote;

  /// No description provided for @invalidUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter a chess.com username: 3 to 25 letters, digits, _ or -.'**
  String get invalidUsername;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'No chess.com account has that name.'**
  String get userNotFound;

  /// No description provided for @chessComBusy.
  ///
  /// In en, this message translates to:
  /// **'chess.com is busy. Try again in a minute.'**
  String get chessComBusy;

  /// No description provided for @chessComError.
  ///
  /// In en, this message translates to:
  /// **'chess.com answered with an error ({status}).'**
  String chessComError(int status);

  /// No description provided for @newGames.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No new games} =1{1 new game} other{{count} new games}}'**
  String newGames(int count);

  /// No description provided for @loadOlderGames.
  ///
  /// In en, this message translates to:
  /// **'Load older games'**
  String get loadOlderGames;

  /// No description provided for @allGamesLoaded.
  ///
  /// In en, this message translates to:
  /// **'All games loaded'**
  String get allGamesLoaded;

  /// No description provided for @noGamesYet.
  ///
  /// In en, this message translates to:
  /// **'No games yet. Enter a chess.com username and fetch.'**
  String get noGamesYet;

  /// No description provided for @gameOpponent.
  ///
  /// In en, this message translates to:
  /// **'vs {name} ({rating})'**
  String gameOpponent(String name, int rating);

  /// No description provided for @resultWin.
  ///
  /// In en, this message translates to:
  /// **'Win'**
  String get resultWin;

  /// No description provided for @resultDraw.
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get resultDraw;

  /// No description provided for @resultLoss.
  ///
  /// In en, this message translates to:
  /// **'Loss'**
  String get resultLoss;

  /// No description provided for @timeClassBullet.
  ///
  /// In en, this message translates to:
  /// **'Bullet'**
  String get timeClassBullet;

  /// No description provided for @timeClassBlitz.
  ///
  /// In en, this message translates to:
  /// **'Blitz'**
  String get timeClassBlitz;

  /// No description provided for @timeClassRapid.
  ///
  /// In en, this message translates to:
  /// **'Rapid'**
  String get timeClassRapid;

  /// No description provided for @timeClassDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get timeClassDaily;

  /// No description provided for @timeControlDays.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day} other{{days} days}} per move'**
  String timeControlDays(int days);

  /// No description provided for @playedWhite.
  ///
  /// In en, this message translates to:
  /// **'You played White'**
  String get playedWhite;

  /// No description provided for @playedBlack.
  ///
  /// In en, this message translates to:
  /// **'You played Black'**
  String get playedBlack;

  /// No description provided for @analyseRecentGames.
  ///
  /// In en, this message translates to:
  /// **'Analyse recent games'**
  String get analyseRecentGames;

  /// No description provided for @analysingGame.
  ///
  /// In en, this message translates to:
  /// **'Analysing game {index} of {total}'**
  String analysingGame(int index, int total);

  /// No description provided for @stopAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopAnalysis;

  /// No description provided for @analysisStoppedBattery.
  ///
  /// In en, this message translates to:
  /// **'Analysis stopped: battery low.'**
  String get analysisStoppedBattery;

  /// No description provided for @gameAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy {value}'**
  String gameAccuracy(String value);

  /// No description provided for @moveLabelBook.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get moveLabelBook;

  /// No description provided for @moveLabelForced.
  ///
  /// In en, this message translates to:
  /// **'Forced'**
  String get moveLabelForced;

  /// No description provided for @moveLabelBrilliant.
  ///
  /// In en, this message translates to:
  /// **'Brilliant'**
  String get moveLabelBrilliant;

  /// No description provided for @moveLabelGreat.
  ///
  /// In en, this message translates to:
  /// **'Great'**
  String get moveLabelGreat;

  /// No description provided for @moveLabelBest.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get moveLabelBest;

  /// No description provided for @moveLabelExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get moveLabelExcellent;

  /// No description provided for @moveLabelGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get moveLabelGood;

  /// No description provided for @moveLabelInaccuracy.
  ///
  /// In en, this message translates to:
  /// **'Inaccuracy'**
  String get moveLabelInaccuracy;

  /// No description provided for @moveLabelMistake.
  ///
  /// In en, this message translates to:
  /// **'Mistake'**
  String get moveLabelMistake;

  /// No description provided for @moveLabelBlunder.
  ///
  /// In en, this message translates to:
  /// **'Blunder'**
  String get moveLabelBlunder;

  /// No description provided for @moveLabelMiss.
  ///
  /// In en, this message translates to:
  /// **'Miss'**
  String get moveLabelMiss;

  /// No description provided for @analysisQuick.
  ///
  /// In en, this message translates to:
  /// **'Quick'**
  String get analysisQuick;

  /// No description provided for @analysisStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get analysisStandard;

  /// No description provided for @reviewBestWas.
  ///
  /// In en, this message translates to:
  /// **'Best was {best}'**
  String reviewBestWas(String best);

  /// No description provided for @reviewTimeSpent.
  ///
  /// In en, this message translates to:
  /// **'{seconds} s'**
  String reviewTimeSpent(String seconds);

  /// No description provided for @reviewStart.
  ///
  /// In en, this message translates to:
  /// **'Start position'**
  String get reviewStart;

  /// No description provided for @retryPrompt.
  ///
  /// In en, this message translates to:
  /// **'Find a better move than {san}.'**
  String retryPrompt(String san);

  /// No description provided for @retryWrong.
  ///
  /// In en, this message translates to:
  /// **'Not the best move. Try again.'**
  String get retryWrong;

  /// No description provided for @retryCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct: {san} was best.'**
  String retryCorrect(String san);

  /// No description provided for @retryExit.
  ///
  /// In en, this message translates to:
  /// **'Back to review'**
  String get retryExit;

  /// No description provided for @gameNotFound.
  ///
  /// In en, this message translates to:
  /// **'This game is no longer stored.'**
  String get gameNotFound;

  /// No description provided for @repertoireLink.
  ///
  /// In en, this message translates to:
  /// **'Repertoire'**
  String get repertoireLink;

  /// No description provided for @linkNoRepertoire.
  ///
  /// In en, this message translates to:
  /// **'No repertoire for this colour.'**
  String get linkNoRepertoire;

  /// No description provided for @linkUserLeft.
  ///
  /// In en, this message translates to:
  /// **'You left the repertoire at {move} {san}. The repertoire plays {book}.'**
  String linkUserLeft(String move, String san, String book);

  /// No description provided for @linkOpponentLeft.
  ///
  /// In en, this message translates to:
  /// **'Your opponent left the repertoire at {move} {san}. Not covered yet.'**
  String linkOpponentLeft(String move, String san);

  /// No description provided for @linkRepertoireEnd.
  ///
  /// In en, this message translates to:
  /// **'The game followed the repertoire to its end; {move} {san} came after it.'**
  String linkRepertoireEnd(String move, String san);

  /// No description provided for @linkGameEnd.
  ///
  /// In en, this message translates to:
  /// **'The game ended inside the repertoire.'**
  String get linkGameEnd;

  /// No description provided for @linkRecord.
  ///
  /// In en, this message translates to:
  /// **'Your games reaching this position: {wins} W, {draws} D, {losses} L'**
  String linkRecord(int wins, int draws, int losses);

  /// No description provided for @addToRepertoire.
  ///
  /// In en, this message translates to:
  /// **'Add to repertoire'**
  String get addToRepertoire;

  /// No description provided for @uncoveredReplies.
  ///
  /// In en, this message translates to:
  /// **'Uncovered opponent replies in your games'**
  String get uncoveredReplies;

  /// No description provided for @uncoveredReply.
  ///
  /// In en, this message translates to:
  /// **'{move} {san} after {path}: {count, plural, =1{1 game} other{{count} games}}'**
  String uncoveredReply(String move, String san, String path, int count);

  /// No description provided for @summaryIntro.
  ///
  /// In en, this message translates to:
  /// **'Let\'s review some key moments from your game.'**
  String get summaryIntro;

  /// No description provided for @summaryPlayers.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get summaryPlayers;

  /// No description provided for @summaryAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get summaryAccuracy;

  /// No description provided for @summaryRating.
  ///
  /// In en, this message translates to:
  /// **'Game rating (estimate)'**
  String get summaryRating;

  /// No description provided for @continueReview.
  ///
  /// In en, this message translates to:
  /// **'Continue review'**
  String get continueReview;

  /// No description provided for @reviewNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get reviewNext;

  /// No description provided for @reviewShow.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get reviewShow;

  /// No description provided for @reviewBest.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get reviewBest;

  /// No description provided for @reviewRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get reviewRetry;

  /// No description provided for @backToSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get backToSummary;

  /// No description provided for @reviewOpening.
  ///
  /// In en, this message translates to:
  /// **'Opening: {name}'**
  String reviewOpening(String name);

  /// No description provided for @reviewLine.
  ///
  /// In en, this message translates to:
  /// **'Engine line: {line}'**
  String reviewLine(String line);

  /// No description provided for @moveTitleBook.
  ///
  /// In en, this message translates to:
  /// **'{san} is a book move'**
  String moveTitleBook(String san);

  /// No description provided for @moveTitleForced.
  ///
  /// In en, this message translates to:
  /// **'{san} was forced'**
  String moveTitleForced(String san);

  /// No description provided for @moveTitleBrilliant.
  ///
  /// In en, this message translates to:
  /// **'{san} is brilliant'**
  String moveTitleBrilliant(String san);

  /// No description provided for @moveTitleGreat.
  ///
  /// In en, this message translates to:
  /// **'{san} is a great move'**
  String moveTitleGreat(String san);

  /// No description provided for @moveTitleBest.
  ///
  /// In en, this message translates to:
  /// **'{san} is the best move'**
  String moveTitleBest(String san);

  /// No description provided for @moveTitleExcellent.
  ///
  /// In en, this message translates to:
  /// **'{san} is excellent'**
  String moveTitleExcellent(String san);

  /// No description provided for @moveTitleGood.
  ///
  /// In en, this message translates to:
  /// **'{san} is good'**
  String moveTitleGood(String san);

  /// No description provided for @moveTitleInaccuracy.
  ///
  /// In en, this message translates to:
  /// **'{san} is an inaccuracy'**
  String moveTitleInaccuracy(String san);

  /// No description provided for @moveTitleMistake.
  ///
  /// In en, this message translates to:
  /// **'{san} is a mistake'**
  String moveTitleMistake(String san);

  /// No description provided for @moveTitleBlunder.
  ///
  /// In en, this message translates to:
  /// **'{san} is a blunder'**
  String moveTitleBlunder(String san);

  /// No description provided for @moveTitleMiss.
  ///
  /// In en, this message translates to:
  /// **'{san} is a miss'**
  String moveTitleMiss(String san);

  /// No description provided for @reviewAnalysing.
  ///
  /// In en, this message translates to:
  /// **'Analysing ({profile}) {done} / {total}'**
  String reviewAnalysing(String profile, int done, int total);

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectedCount(int count);

  /// No description provided for @selectAllGames.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get selectAllGames;

  /// No description provided for @reviewSelected.
  ///
  /// In en, this message translates to:
  /// **'Review selected games'**
  String get reviewSelected;

  /// No description provided for @rerunSelected.
  ///
  /// In en, this message translates to:
  /// **'Re-run selected reviews'**
  String get rerunSelected;

  /// No description provided for @clearSelection.
  ///
  /// In en, this message translates to:
  /// **'Clear selection'**
  String get clearSelection;

  /// No description provided for @rerunReview.
  ///
  /// In en, this message translates to:
  /// **'Re-run review'**
  String get rerunReview;

  /// No description provided for @rerunReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Re-run this review?'**
  String get rerunReviewTitle;

  /// No description provided for @rerunReviewBody.
  ///
  /// In en, this message translates to:
  /// **'The stored analysis of this game is replaced by a new one. It takes a minute or two.'**
  String get rerunReviewBody;

  /// No description provided for @rerunConfirm.
  ///
  /// In en, this message translates to:
  /// **'Re-run'**
  String get rerunConfirm;

  /// No description provided for @summaryChessComAccuracy.
  ///
  /// In en, this message translates to:
  /// **'chess.com accuracy'**
  String get summaryChessComAccuracy;

  /// No description provided for @summaryCapped.
  ///
  /// In en, this message translates to:
  /// **'{count} positions hit the time limit and were searched less deeply than Standard depth, so these scores may be slightly off.'**
  String summaryCapped(int count);

  /// No description provided for @calibrateScores.
  ///
  /// In en, this message translates to:
  /// **'Fit accuracy to chess.com'**
  String get calibrateScores;

  /// No description provided for @calibrateTitle.
  ///
  /// In en, this message translates to:
  /// **'Fit accuracy to chess.com'**
  String get calibrateTitle;

  /// No description provided for @calibrateTooFew.
  ///
  /// In en, this message translates to:
  /// **'Needs at least {count} reviewed games that carry chess.com\'s own accuracy. Fetch the games again, then analyse them.'**
  String calibrateTooFew(int count);

  /// No description provided for @calibrateDone.
  ///
  /// In en, this message translates to:
  /// **'Fitted to {games} player-games: decay {decay}, mean difference to chess.com {error} points (bias {bias}). All reviewed games were re-scored.'**
  String calibrateDone(int games, String decay, String error, String bias);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
