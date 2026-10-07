import 'package:chess_core/chess_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings.freezed.dart';
part 'app_settings.g.dart';

/// When opponent deviations may happen (D-07).
enum DeviationTiming {
  /// Only after the line's last book move (default).
  endOfLine,

  /// Anywhere in the line.
  anywhere,
}

/// Board animation speed.
enum AnimationSpeed {
  /// 300 ms.
  slow(300),

  /// 200 ms (default).
  normal(200),

  /// 120 ms.
  fast(120),

  /// No animation.
  off(0);

  new(this.ms);

  /// Duration in milliseconds.
  final int ms;
}

/// Light / dark theme choice.
enum AppThemeMode {
  /// Dark (default, D-25).
  dark,

  /// Light.
  light,

  /// Follow the system.
  system,
}

/// Every device-local setting with its default
/// (docs/plan/01-product-spec.md §10). Stored one key per field in the
/// `settings` table (JSON values), so new settings get their default.
@freezed
abstract class AppSettings with _$AppSettings {
  /// Creates settings; omitted fields take their defaults.
  const factory({
    // Training.
    @Default(WrongMoveMode.retry) WrongMoveMode wrongMoveMode,
    @Default(false) bool showLineSummary,
    @Default(1500) int autoAdvanceDelayMs,
    @Default(250) int opponentMoveDelayMs,
    @Default(true) bool showComments,
    @Default(true) bool showCommentArrows,
    @Default(false) bool deviationsEnabled,
    @Default(25) int deviationChancePercent,
    @Default(DeviationTiming.endOfLine) DeviationTiming deviationTiming,
    @Default(80) int weakEnterBelowPercent,
    @Default(defaultWeakExitCleanRuns) int weakExitCleanRuns,
    @Default(defaultSrsNewPerDay) int srsNewPerDay,

    /// Null = unlimited.
    int? srsMaxReviewsPerDay,
    @Default(defaultDayStartHour) int dayStartHour,

    /// Drills start at the line's branch point instead of move 1 (the
    /// default for the mode sheet, 01-product-spec §7.1).
    @Default(false) bool startFromBranchPoint,

    /// Eval bar beside the drill board (toggled from the drill app bar).
    @Default(false) bool drillEvalBar,
    // Board and sound.
    @Default('brown') String boardTheme,
    @Default('cburnett') String pieceSet,
    @Default(true) bool showCoordinates,
    @Default(true) bool showLegalMoves,
    @Default(true) bool highlightLastMove,
    @Default(AnimationSpeed.normal) AnimationSpeed animationSpeed,
    @Default(true) bool soundsEnabled,
    @Default(80) int soundVolumePercent,
    @Default(true) bool hapticsEnabled,
    // Engine.
    @Default(defaultComparableThresholdCp) int comparableThresholdCp,
    @Default(1000) int checkSearchMs,

    /// Null = auto (docs/plan/05-engine.md §3).
    int? engineThreads,

    /// Null = auto.
    int? engineHashMb,

    /// UCI_Elo for play-on (1500, 2000, 2500); 0 = full strength.
    @Default(2500) int playOnElo,

    /// Windows: the engine variant that answered (avx2 / sse41), if known.
    String? engineVariant,

    /// Number of lines in Browse analysis (01-product-spec §9).
    @Default(1) int analysisLines,

    /// Last chess.com username looked up in Game Review.
    String? chessComUsername,
    // Appearance.
    @Default(AppThemeMode.dark) AppThemeMode themeMode,
  }) = _AppSettings;

  /// Parses the merged key/value JSON.
  factory fromJson(Map<String, dynamic> json) => _$AppSettingsFromJson(json);

  const new _();

  /// A copy with every numeric setting clamped to its allowed range.
  AppSettings normalized() => copyWith(
    autoAdvanceDelayMs: _step(autoAdvanceDelayMs, 0, 5000, 500),
    opponentMoveDelayMs: _step(opponentMoveDelayMs, 0, 1500, 50),
    deviationChancePercent: _step(deviationChancePercent, 0, 100, 5),
    weakEnterBelowPercent: _step(weakEnterBelowPercent, 50, 95, 5),
    weakExitCleanRuns: weakExitCleanRuns.clamp(1, 10),
    srsNewPerDay: srsNewPerDay.clamp(0, 100),
    srsMaxReviewsPerDay: srsMaxReviewsPerDay?.clamp(10, 500),
    dayStartHour: dayStartHour.clamp(0, 6),
    soundVolumePercent: soundVolumePercent.clamp(0, 100),
    comparableThresholdCp: comparableThresholdCp.clamp(10, 100),
    checkSearchMs: checkSearchMs.clamp(500, 3000),
    engineThreads: engineThreads?.clamp(1, 1024),
    engineHashMb: engineHashMb?.clamp(16, 1024),
    analysisLines: analysisLines.clamp(1, 3),
  );

  /// Weak-pool entry threshold as a fraction.
  double get weakEnterBelow => weakEnterBelowPercent / 100;

  /// The settings that change derived stats.
  DeriveSettings get deriveSettings => DeriveSettings(
    weakEnterBelow: weakEnterBelow,
    weakExitCleanRuns: weakExitCleanRuns,
  );
}

int _step(int v, int min, int max, int step) =>
    (((v.clamp(min, max) - min) / step).round() * step + min).clamp(min, max);
