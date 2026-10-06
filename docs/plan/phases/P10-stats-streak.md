# P10. Stats screens and daily streak

**Depends on:** P08 (P09 for the deviation section; build it behind a "has deviation data" check so P10 can merge first).
**Read first:** [01-product-spec.md §4 (streak card), §11, §12](../01-product-spec.md), [04-algorithms.md §2, §9](../04-algorithms.md).

## Goal
The per-repertoire stats screen, line detail, most-missed moves, deviation stats, and the streak on Home.

## Tasks
1. `StatsQueries` (SQL in `core/db`): daily aggregates per repertoire (credit sum, graded sum, run count by `localDay`), most-missed plies (group `move_grades` by node path: join runs.ucis prefix to ply → node; compute misses/attempts with min 3), run history per line (direct + inherited + archived via attribution in Dart, since attribution is sequence-based), deviation aggregates.
2. Stats screen sections 1-5 per [01-product-spec.md §11](../01-product-spec.md); `fl_chart` line chart with 7-day moving average and runs-per-day bars; range chips; full sortable/filterable line list.
3. Line detail screen with run history (marks per move), per-move error table, weak/SRS state, Drill this line, Browse this line; archived lines read-only.
4. Streak: `StreakService` over `runs.localDay` (all repertoires) per [04-algorithms.md §9](../04-algorithms.md); Home streak card per §4; updates live after a run.
5. Session summary sheet shows streak status ("Streak: 12 days, today done").
6. All derived numbers come from `line_stats` or the queries above; nothing recomputed in widgets.

## Tests
- Queries against fixture DBs with known answers (daily aggregates, most-missed, inherited/archived attribution in history).
- Chart data transformation (moving average, gaps on days without runs).
- Streak cases from [04-algorithms.md §9](../04-algorithms.md) through the service with fake clock.
- Widget tests: empty stats (no runs), populated, archived line view.
- Performance: stats screen opens < 300 ms with 20k runs on Linux (integration timing).

## Acceptance criteria
- Every element of §11 and §12 implemented; numbers match the pure P02 functions on the same data (cross-check test).

## Device checklist (Eli)
- [ ] After a few days of use, the chart and worst lines match your impression.
- [ ] Streak counts today after one line and survives until 04:00 the next night.
