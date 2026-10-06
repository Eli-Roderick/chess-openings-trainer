# P08. Training modes: weak pool, spaced repetition, single line, summaries

**Depends on:** P07.
**Read first:** [01-product-spec.md §4 (Continue, counts), §6, §7.1, §7.9 (summary), §7.11, §7.12](../01-product-spec.md), [04-algorithms.md §3.4, §4, §5](../04-algorithms.md), [11-decisions.md D-01, D-02, D-16, D-17](../11-decisions.md).

## Goal
All three training modes plus single-line drills, the mode sheet, the line summary screen, and the counts on Home and detail screens.

## Tasks
1. Picker abstraction `LinePicker` with implementations `RandomPicker` (exists), `WeakPicker`, `SrsPicker` (wrapping P02 logic with live `line_stats`), `SingleLinePicker`; branch-switch rule per mode ([04-algorithms.md §3.4](../04-algorithms.md)).
2. Mode sheet per [01-product-spec.md §7.1](../01-product-spec.md); remembers start-from per repertoire and last mode; deviations switch shown but disabled until P09.
3. SRS: due/new counts, "All caught up" screen with next due date and counts, relearn of failed lines within the session (failed line re-enters as due today; exclusion keeps it 3 lines away), new-per-day and max-reviews settings, day-start setting (Settings → Training).
4. Weak mode: pool size in app bar, empty-pool screen, weak thresholds settings (trigger re-derivation via `StatsService`).
5. Line summary screen per §7.9 and "Show line summary" setting; end bar Summary button now visible. Before/after accuracy, weak pool change, SRS next due.
6. Drill this line (`single` mode) entry point used by Line detail in P10 (route param `line=`), and "Retry this line" in the summary.
7. Home: Continue button (last repertoire + last mode), accuracy/due/weak counts on cards; Repertoire detail counts (coverage, weak, due, new available).

## Tests
- Pickers: Weak picks only pool lines; SRS order (learning first, overdue ratio, interleave every 4th new), quota across day boundary with fake clock, max-reviews cap, exclusion; Single always the same line.
- Controller with each picker: SRS fail → line returns later in the same session; Weak line leaves pool after 3 clean runs and the session continues with the rest of the pool; empty-pool screen.
- Summary screen content for a run with mixed grades, and for weak/SRS state changes.
- Integration flows 8 and 9 from [10-testing-and-quality.md §3](../10-testing-and-quality.md).

## Acceptance criteria
- Every behaviour in the sections listed above works; counts on Home update live after a run.

## Device checklist (Eli)
- [ ] SRS: train new lines today; tomorrow the passed ones are not due and failed ones are.
- [ ] Deliberately miss a line 2-3 times: it shows in Weak lines; three clean runs remove it.
- [ ] Turn on line summary; check it shows comments for missed moves.
