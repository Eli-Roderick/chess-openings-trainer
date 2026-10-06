# P13. Performance pass, polish and release

**Depends on:** all previous phases.
**Read first:** [10-testing-and-quality.md §5, §6](../10-testing-and-quality.md), [02-architecture.md §5, §6](../02-architecture.md), [01-product-spec.md §3, §15, §16](../01-product-spec.md).

## Goal
Hit every performance target on Eli's devices, finish the remaining polish items, and produce signed release builds.

## Tasks
1. Profile on Linux profile builds and analyse Eli's Diagnostics numbers from earlier checklists; fix anything over target: startup path (defer more, smaller first query), board rebuilds (verify with `debugProfileBuildsEnabled` in a test harness), image precache, list virtualization, isolate use.
2. Startup: Android 12+ splash using the app icon and dark background (no extra splash package unless needed); make sure nothing heavy runs before the first frame.
3. App icon (`flutter_launcher_icons`) for Android (adaptive) and Windows; final app name decision with Eli (rename is find-and-replace of the working name if he wants another).
4. Android intent filter to open `.pgn` files from file managers and the share sheet → Create screen prefilled (choose repertoire or create new).
5. Windows: remember window size/position, min size 900x600, keyboard shortcut overlay (`?` key shows the shortcut list), Ctrl+, opens Settings.
6. Accessibility pass: semantics labels on all icon buttons, contrast check of dark and light themes (WCAG AA for text), text scale 1.3 on every screen.
7. Error handling sweep: every repository/engine/sync failure surfaces a readable message; Diagnostics "Export logs".
8. Release pipeline: `release.yml` builds signed arm64 + armv7 APKs and the Windows zip on tag; GitHub release notes generated from `docs/PROGRESS.md` and CHANGELOG; GPL source link for Stockfish.
9. `README.md` final: install on Android (sideload steps), Windows (unzip, run), building from source, Google setup, annotation workflow (link to the prompt), licence.
10. Final full run of all integration flows; update `docs/PROGRESS.md`.

## Acceptance criteria (on Eli's devices; measured via Diagnostics, release build)
- Cold start < 1.5 s to usable Home.
- Drill: < 1 % frames over budget across 20 lines; worst raster < 2× budget.
- Drill latency p95 ≤ 300 ms.
- Import benchmark (1,000 lines) < 2 s.
- Stats screen opens < 300 ms with Eli's real data.
- No crash or unhandled error in logs across one week of normal use.

## Device checklist (Eli)
- [ ] Record the Diagnostics numbers above and paste them into the thread.
- [ ] Open a .pgn from the phone's file manager into the app.
- [ ] Install the tagged release APK over the build you have been testing; data stays intact (same signing key since P00).
