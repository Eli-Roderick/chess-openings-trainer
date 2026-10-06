# 04. Algorithms

All of this lives in `packages/chess_core/lib/src/training/` as pure functions over plain data, with injected `Clock` and `Rng` (seedable `Random` wrapper). Each section lists the tests it needs. Numbers marked **[setting]** come from settings; the rest are constants in `training/constants.dart`.

## 1. Grading a user move and finalizing a run

Per graded ply the drill keeps a `PlyGrade` builder:

```
onFirstEvent(ply):                      # first attempt or first hint at this ply
  if hint pressed before any attempt:   result = hint,  credit = 0
  elif first attempt in accepted set:   result = correct, credit = 1
  else:                                 result = wrong, credit = 0, queue comparable check(firstAttempt)
on hint pressed later at the same ply:  result = hint, credit = 0   (overrides wrong/comparable)
on comparable check result for this ply:
  if result == wrong and check.comparable: result = comparable, credit = 0.5
  record checkCp, checkStatus
```
- Only plies with ply > run.startPly and on the user's side are graded.
- In Restart mode, a ply graded once keeps its grade for the rest of the run.
- Alternative repertoire moves (another child of the node) are `correct`.
- Run finalize: `completed = true` when the leaf was reached (or the deviation reply judged). Wait for pending checks up to **3 s**; unresolved → `checkStatus = timeout`, credit stays 0. `gradedCount`, `creditSum`, `hintCount` computed from grades. Persist run + grades (+ deviation event) in one transaction.
- Abandoned run: persisted with `completed = false` and whatever grades exist. Excluded from stats.

**Tests:** each transition; hint after wrong; check arriving after the run finalized timeout; restart mode not regrading; alt-move correct.

## 2. Accuracy

### 2.1 Eligible runs
A run is eligible for line L if `completed && gradedCount > 0` and it is attributed to L directly or by inheritance ([03-data-model.md §5](03-data-model.md)). Runs with an end-of-line challenge are ordinary runs. Mid-line deviated runs are eligible too (their pre-deviation graded moves count).

### 2.2 Line accuracy
```
window   = last 10 eligible runs of L by finishedAt (ties: id)
accuracy = sum(run.creditSum for run in window) / sum(run.gradedCount for run in window)
```
Move-weighted, so a short branch-point run counts less than a full run. `null` when no eligible runs. Displayed as an integer percent (round half up).

### 2.3 Overall repertoire accuracy
Mean of line accuracies over lines (non-archived) with non-null accuracy. Each line weighs the same, so many runs of one easy line cannot hide weak ones.

### 2.4 Daily accuracy (chart)
For local day D: `sum(creditSum) / sum(gradedCount)` over eligible runs with `localDay == D`, all lines of the repertoire.

**Tests:** window boundary at 10; inherited runs included; abandoned excluded; deviated included; null cases; rounding.

## 3. Weighted random picker (Random mode)

### 3.1 Weight
```
hours   = lastPlayedAt == null ? 168 : min(168, (now - lastPlayedAt) / 3_600_000)
R       = hours / 168                        # 0..1, saturates after 7 days
acc     = accuracy ?? 0.5
W       = 1 + 3 * (1 - acc)                  # 1 (perfect) .. 4 (0 %)
weight  = (0.25 + R) * W
```
`lastPlayedAt` = latest `finishedAt` among eligible runs (direct or inherited). Resulting range: a perfect line played an hour ago ≈ 0.26; an untrained line 3.1; a 50 % line untouched for a week 3.1; a 0 % line untouched for a week 5.0. Constants (168, 0.25, 3, 0.5) live in `constants.dart`.

### 3.2 Exclusion
Lines with `userMoveCount == 0` are never candidates in any mode (and `lineCount` below counts only trainable lines).
`recent` = distinct line keys of the last runs started in this repertoire (any mode, completed or abandoned, from the DB plus the current session) in start order, newest first, taking the first `k = min(3, lineCount - 1)` distinct keys. Those lines get weight 0. If `lineCount == 1` the single line is always picked.

### 3.3 Sampling
Cumulative sum over lines in `ordinal` order, `x = rng.nextDouble() * total`, first line with cumulative > x. Deterministic with a seeded Rng.

### 3.4 Branch switch
When the user plays an alternative repertoire move at node N to child C: candidates = lines whose path contains C. Use the active mode's rule restricted to candidates (Random: §3 weights without exclusion; Weak: pool lines first, else Random rule; SRS: due lines first, else Random rule; Single: Random rule). Pick and continue.

**Tests:** weights for each boundary; exclusion with 1, 2, 3, 4 lines; distribution test (100k picks, seeded, each line's frequency within ±2 % of weight share); never picks excluded line; branch switch candidates correct.

## 4. Weak pool

Membership is derived by replaying eligible runs of each line in finish order:

```
inPool = false; streak = 0
for run in eligibleRuns(L) ordered by finishedAt:
  acc  = line accuracy over the last 10 eligible runs up to and including this run
  allPerfect = every graded credit in run == 1
  if run.deviated and allPerfect: continue            # mid-line deviation, partial line: no evidence either way
  clean = allPerfect and not run.deviated
  if inPool:
    if clean: streak += 1; if streak >= exitCleanRuns [setting, 3]: inPool = false; streak = 0
    else:     streak = 0
  else:
    if not clean and acc < enterBelow [setting, 0.80]: inPool = true; streak = 0
```
- Entry is only evaluated after a non-clean run (hysteresis). Otherwise a line that just left after 3 clean runs could immediately re-enter because its 10-run window still contains old failures.
- Changing either threshold triggers a full re-derivation (cheap).
- **Weak mode picker:** §3 weights and exclusion restricted to pool lines. Exclusion `k = min(3, poolSize - 1)`. Empty pool → "No weak lines" screen.

**Tests:** entry at 79 % vs 80 %; exit after exactly 3 clean; reset on non-clean; hysteresis case; deviated perfect run neutral; deviated imperfect run resets; threshold change re-derivation.

## 5. Spaced repetition (SRS)

SM-2 variant per line. Decided parameters and reasons in [11-decisions.md D-01](11-decisions.md).

### 5.1 State
`state ∈ {new, learning, review}`, `reps` (successful reviews in a row), `ease` (initial 2.5, min 1.3, max 3.0), `intervalDays`, `dueDay`, `lapses`, `firstSeenDay`.

### 5.2 Review events
Derived by replaying runs of line L in finish order. A run is an **SRS review** of L if: `mode == srs`, attributed **directly** (not inherited), `completed`, `!deviated`, `gradedCount > 0`. Let `D = run.localDay`, `a = creditSum / gradedCount`, `pass = a >= 0.90`, `q = (a == 1.0) ? 5 : 4` on pass.

```
if state == review and dueDay > D:        # reviewed early (only possible via branch switch)
    if pass: ignore                        # no schedule change
    else: lapse()                          # a failure is always informative
    continue
if firstSeenDay == null: firstSeenDay = D
if pass:
    if state in {new, learning}: reps = 1; interval = 1
    elif reps == 1:              reps = 2; interval = 4
    else:                        reps += 1; interval = ceil(interval * ease)
    ease = clamp(ease + (q == 5 ? 0.10 : 0.0), 1.3, 3.0)
    if interval >= 4: interval = interval + round(interval * fuzz(L.key, reps))   # fuzz ∈ [-0.10, +0.10]
    interval = min(interval, 180)
    state = review; dueDay = D + interval
else:
    lapse()

lapse():
    lapses += 1; reps = 0; ease = max(1.3, ease - 0.20)
    state = learning; interval = 0; dueDay = D         # due again today: relearn in this session
```
`fuzz(key, reps)` = deterministic: first 4 bytes of SHA-256(`key:reps`) as uint32 / 2^32 * 0.2 - 0.1. Deterministic so every device derives the same schedule from the same runs.

### 5.3 Failures outside SRS mode
A run with `mode != srs`, direct, completed, not deviated, `a < 0.90`, on a line in state `review`: `dueDay = min(dueDay, D)`. No ease or lapse change; the next SRS review grades it properly. Reason: forgetting discovered anywhere should surface in SRS, but practice in other modes should not move the schedule forward.

### 5.4 Inherited and extended lines
An extended line starts SRS as `new` (inherited runs are ignored by SRS). Archived lines have no SRS state shown.

### 5.5 SRS session picker
```
today        = localDay(now)
due          = lines with state in {review, learning} and dueDay <= today
newToday     = count of lines with firstSeenDay == today
newAllowed   = max(0, newPerDay [setting, 10] - newToday)
newQueue     = first newAllowed lines with state == new, by ordinal (PGN order)
reviewsToday = count of SRS reviews with localDay == today
if maxReviewsPerDay is set and reviewsToday >= maxReviewsPerDay: done
order due by: learning first, then overdue ratio (today - dueDay) / max(intervalDays, 1) desc, then ordinal
interleave: every 4th pick is from newQueue if non-empty; otherwise from due; when one runs out, use the other
skip lines in the §3.2 exclusion set when an alternative exists
empty → "All caught up" with the earliest future dueDay and how many lines fall on it
```
New lines are introduced in file order so related lines are learned together.

### 5.6 Single-line drills
`mode == single` runs count for accuracy, weak pool and streak; for SRS only via §5.3.

**Tests:** full replay table tests (sequence of runs → expected state after each); 90 % boundary; fuzz determinism and range; cap 180; early-review pass ignored; early-review fail lapses; non-SRS failure pulls due date; new-per-day quota across days; interleave order; day-start boundary at 04:00.

## 6. Branch point (skip-ahead start)

```
path  = [root, n1, ..., nk]  (nk = leaf)
forks = nodes in path[0..k-1] with children.length >= 2
for F in forks ordered by ply descending:
    if any user move exists in path after F: return F.ply
return 0
```
Starting at ply f means the position after node F; the next move (ply f+1) is the first move that differs between this line and its nearest sibling lines. A line with no fork (single-line repertoire) starts at 0. Precomputed at import into `lines.branchPly`.

**Tests:** no forks; root fork; deepest fork followed only by an opponent leaf move (falls back to the previous fork); user-side fork.

## 7. Engine judgements used by training

### 7.1 Comparable check (decides 0.5 credit)
Inputs: position P before the user move, user move u, accepted repertoire moves A. Engine job in [05-engine.md §5](05-engine.md) returns side-to-move scores `s(m)` for m in A ∪ {u} from one search with `searchmoves`. Convert to centipawns; mate in n for the side to move → `100000 - n`, mated in n → `-100000 + n`.
```
best_rep = max(s(a) for a in A)
loss     = best_rep - s(u)
comparable = loss <= threshold_cp [setting, 30]
```
A user move better than the repertoire move is comparable (loss ≤ 0).

### 7.2 Deviation candidates
Position Q = position where the opponent is to move: after the line's last (user) move for an end-of-line challenge, or at the deviation ply for a mid-line deviation. MultiPV 5, search per [05-engine.md §6](05-engine.md). Candidate set = PV first moves with `score >= bestScore - 100` (opponent's perspective, cp), excluding Q's repertoire children (Q has none at the end of a line). Pick weighted by `(101 - (bestScore - score))`, so near-best moves are likelier. No candidates → no deviation for this run.

### 7.3 Deviation reply judgement
Position after the deviation (or, for an end-of-line challenge on a line ending with an opponent move, the final position of the line), user to move, reply r. One search with MultiPV 1 (best move b, score s_b) and a second search with `searchmoves r` (score s_r), both with the comparable-check budget. `lossCp = s_b - s_r`; `passed = lossCp <= 50`. If r == b, passed with loss 0 without the second search.

**Tests (with fake engine):** mate conversions; tie at threshold; better-than-book move; candidate filtering; empty candidates.

## 8. Stats derivation (`StatsDeriver`)

```
deriveRepertoire(lines, runs (all for repertoire, with grades), settings, today) -> List<LineStats>:
  index current lines by ucis; build a prefix trie of current line ucis
  for each run: attribute → direct line | inherited lines (all current lines extending run.ucis, only if run.ucis is not a current line) | archived key
  for each current line: accuracy (§2), lastPlayedAt, weak pool (§4), SRS (§5, direct runs + §5.3)
  for each archived key with runs: accuracy, lastPlayedAt, archived = true
```
Triggers: after a run is persisted (only the affected line(s): incremental), after import/re-import (whole repertoire), after sync merge (repertoires touched), after threshold/day-start setting change (all). Must handle 50k runs in < 1 s in an isolate (benchmark test with synthetic data).

## 9. Streak

```
days = set of localDay over completed runs (all repertoires, any mode)
today = localDay(now) using current day-start setting
cur = 0; d = today if today in days else yesterday
while d in days: cur += 1; d -= 1 day
best = longest consecutive run of days in sorted(days)
todayDone = today in days
```
**Tests:** empty; today only; yesterday only (streak alive, not done today); gap; best vs current; day-start boundary (a run at 03:30 with day start 04:00 belongs to the previous day).

## 10. Local day

`localDay(instant, dayStartHour) = date(local(instant) - dayStartHour hours)` formatted `YYYY-MM-DD`. Computed once when the run finishes and stored.
