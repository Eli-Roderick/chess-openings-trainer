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

  /// No description provided for @placeholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get placeholderTitle;

  /// No description provided for @placeholderBody.
  ///
  /// In en, this message translates to:
  /// **'This screen arrives in a later version.'**
  String get placeholderBody;

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

  /// No description provided for @settingsLater.
  ///
  /// In en, this message translates to:
  /// **'These settings arrive in a later version.'**
  String get settingsLater;

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
  /// **'Janky frames (over 16.7 ms)'**
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
