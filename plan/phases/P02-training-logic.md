# P02. chess_core: training logic

**Depends on:** P01.
**Read first:** [04-algorithms.md](../04-algorithms.md) (all), [03-data-model.md §1, §2.4-2.7, §5](../03-data-model.md), [11-decisions.md](../11-decisions.md).

## Goal
Every rule that decides grades, accuracy, which line comes next, weak pool, SRS, streak and re-import attribution, as pure, deterministic, exhaustively tested functions.

## Tasks
1. `util/clock.dart` (`Clock` interface, `SystemClock`, `FakeClock`), `util/rng.dart` (`Rng` with `nextDouble`, `nextInt`; `SeededRng`).
2. `training/day_clock.dart`: `localDay(instant, dayStartHour)`, day arithmetic on `YYYY-MM-DD` strings.
3. `training/run.dart`: `RunRecord`, `MoveGrade`, `DeviationEvent` immutable models with `freezed` + `json_serializable` (both are Flutter-free; add them to `chess_core`'s pubspec and run `build_runner` in the package). These are the same shapes as sync JSON in [06-sync.md §2](../06-sync.md).
4. `training/grading.dart`: `PlyGradeBuilder` state machine per [04-algorithms.md §1](../04-algorithms.md); `RunBuilder` that accumulates grades and produces a `RunRecord` (finalize with pending-check timeout semantics expressed as data: pending checks become `timeout`).
5. `training/attribution.dart`: prefix trie of current line ucis; `attribute(run) → Direct(key) | Inherited(keys) | Archived(key)` per [03-data-model.md §5](../03-data-model.md).
6. `training/accuracy.dart`: line accuracy, overall accuracy, daily accuracy.
7. `training/weak_pool.dart`: replay per [04-algorithms.md §4](../04-algorithms.md).
8. `training/srs.dart`: replay per §5 incl. fuzz, §5.3, `SrsPicker` per §5.5.
9. `training/randomizer.dart`: weights, exclusion, sampling, branch-switch candidate selection per §3.
10. `training/streak.dart` per §9.
11. `training/line_stats_deriver.dart`: `deriveRepertoire(...)` and incremental `deriveLines(keys, ...)` per §8 producing `LineStats` values equal in shape to the `line_stats` table.
12. `training/reimport_diff.dart`: unchanged / extended / removed / new + comment change count per [03-data-model.md §5](../03-data-model.md) and [01-product-spec.md §13](../01-product-spec.md).
13. `training/constants.dart` with every constant named in [04-algorithms.md](../04-algorithms.md).

## Tests (minimum)
All test lists in [04-algorithms.md](../04-algorithms.md) §1-§9, plus:
- Attribution with extension to 1 and to 3 lines; shortened line → archived; re-added line → direct again.
- Deriver equivalence: incremental derivation for one line equals full derivation.
- Deriver performance: 50k synthetic runs over 500 lines < 1 s (tag `bench`).
- Randomizer distribution test (seeded, 100k picks, ±2 %).
- SRS table-driven scenarios: at least 12 multi-run scenarios with expected state after each run (written as readable tables in the test).
- Property test: deriving from runs in shuffled insertion order gives identical stats (derivation sorts internally).

## Acceptance criteria
- Coverage of `training/` ≥ 95 %.
- No use of `DateTime.now()` or `Random()` outside `util/`.
- Public API documented with dartdoc on every public member.

## Out of scope
Persistence, UI, engine calls (engine results enter as plain data: `ComparableOutcome {comparable, lossCp, status}`).
