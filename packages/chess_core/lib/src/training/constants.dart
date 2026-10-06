/// Every constant named in docs/plan/04-algorithms.md. Values marked
/// (setting) are defaults of user settings.
library;

// §1 Grading.

/// Credit of a correct move.
const creditCorrect = 1.0;

/// Credit of a comparable (engine-approved) non-repertoire move.
const creditComparable = 0.5;

/// How long a finishing run waits for pending comparable checks.
const pendingCheckTimeout = Duration(seconds: 3);

// §2 Accuracy.

/// Number of most recent eligible runs in a line's accuracy window.
const accuracyWindow = 10;

// §3 Random picker.

/// Hours after which a line's recency factor saturates (7 days).
const recencySaturationHours = 168;

/// Base weight added to the recency factor.
const recencyBase = 0.25;

/// Weight multiplier per unit of inaccuracy: W = 1 + factor * (1 - acc).
const accuracyWeightFactor = 3.0;

/// Accuracy assumed for a line that has never been played.
const unknownAccuracy = 0.5;

/// At most this many recently started lines are excluded from picks.
const maxRecentExclusion = 3;

// §4 Weak pool.

/// (setting) A line enters the weak pool after a non-clean run while its
/// accuracy is below this.
const defaultWeakEnterBelow = 0.80;

/// (setting) Clean runs in a row needed to leave the weak pool.
const defaultWeakExitCleanRuns = 3;

// §5 SRS.

/// A review passes at this accuracy or above.
const srsPassAccuracy = 0.90;

/// Ease of a line that has never been reviewed.
const srsInitialEase = 2.5;

/// Lowest ease.
const srsMinEase = 1.3;

/// Highest ease.
const srsMaxEase = 3.0;

/// Ease added by a perfect review.
const srsPerfectEaseBonus = 0.10;

/// Ease removed by a lapse.
const srsLapseEasePenalty = 0.20;

/// Interval after the first successful review, in days.
const srsFirstIntervalDays = 1;

/// Interval after the second successful review, in days.
const srsSecondIntervalDays = 4;

/// Intervals of at least this many days get the deterministic fuzz.
const srsFuzzFromDays = 4;

/// The fuzz is within ± this fraction of the interval.
const srsFuzzRange = 0.10;

/// Longest interval, in days.
const srsMaxIntervalDays = 180;

/// (setting) New lines introduced per day.
const defaultSrsNewPerDay = 10;

/// Every this-many-th pick of an SRS session is a new line (if any).
const srsNewLineEvery = 4;

// §7 Engine judgements.

/// (setting) A non-repertoire move losing at most this many centipawns
/// against the best repertoire move is comparable (0.30 pawns).
const defaultComparableThresholdCp = 30;

/// Centipawn value of "mate in 0"; mate in n is this minus n.
const mateScoreCp = 100000;

/// Deviation candidates are within this many centipawns of the best move.
const deviationWindowCp = 100;

/// Deviation candidates are weighted by (base - (best - score)).
const deviationWeightBase = 101;

/// Number of principal variations searched for deviation candidates.
const deviationMultiPv = 5;

/// A deviation reply passes when it loses at most this many centipawns.
const deviationReplyPassCp = 50;

// §10 Local day.

/// (setting) Hour (local time) at which a new training day starts.
const defaultDayStartHour = 4;
