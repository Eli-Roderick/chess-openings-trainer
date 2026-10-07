# Progress

One PR per phase, in order (`docs/plan/README.md`). A phase is "done" when its PR is merged with CI green.

| Phase | Name | Status | PR |
|---|---|---|---|
| P00 | Repository bootstrap and CI | done | [#1](https://github.com/Eli-Roderick/chess-openings-trainer/pull/1) |
| P01 | PGN import, comments, validation, lines (pure Dart) | done | [#2](https://github.com/Eli-Roderick/chess-openings-trainer/pull/2) |
| P02 | Training logic: grading, accuracy, randomizer, weak pool, SRS, streak (pure Dart) | done | [#3](https://github.com/Eli-Roderick/chess-openings-trainer/pull/3) |
| P03 | Database, repositories, settings, stats derivation | done | [#4](https://github.com/Eli-Roderick/chess-openings-trainer/pull/4) |
| P04 | App shell, Home, create/import/re-import, management | done | [#5](https://github.com/Eli-Roderick/chess-openings-trainer/pull/5) |
| P05 | Board, sounds, Browse | done | [#6](https://github.com/Eli-Roderick/chess-openings-trainer/pull/6) |
| P06 | Stockfish service, analysis board, engine settings | done | [#7](https://github.com/Eli-Roderick/chess-openings-trainer/pull/7) |
| P07 | Drill core in Random mode | done | [#8](https://github.com/Eli-Roderick/chess-openings-trainer/pull/8) |
| P08 | Weak pool, SRS, single line, summaries | done | [#9](https://github.com/Eli-Roderick/chess-openings-trainer/pull/9) |
| P09 | Opponent deviations, play on vs engine | done | [#10](https://github.com/Eli-Roderick/chess-openings-trainer/pull/10) |
| P10 | Stats screens, streak | done | [#11](https://github.com/Eli-Roderick/chess-openings-trainer/pull/11) |
| P11 | Backup and sync core (codec, merge) | done | [#12](https://github.com/Eli-Roderick/chess-openings-trainer/pull/12) |
| P12 | Google Drive sync | done | [#13](https://github.com/Eli-Roderick/chess-openings-trainer/pull/13) |
| P13 | Performance pass, polish, release | done | [#14](https://github.com/Eli-Roderick/chess-openings-trainer/pull/14) |

## P13 (performance, polish, release)

Details of the plan corrections are in `docs/plan/corrections/P13.md`.

**D-110 Icon, splash, name.** Knight icon (adaptive on Android, `.ico` on Windows) via `flutter_launcher_icons`; dark launch background and the Android 12+ splash from the theme; working name kept.

**D-111 Opening PGN files on Android.** VIEW and SEND intent filters; a file opens Create prefilled, or a sheet to create or re-import.

**D-112 Windows window and shortcuts.** Size and position remembered, minimum 900 x 600; `?` lists shortcuts, Ctrl+, opens Settings.

**D-113 Accessibility.** Tooltips on every icon button; status colours readable in both themes (WCAG AA, tested); every screen tested at text scale 1.3 on a small phone.

**D-114 Errors.** Readable one-line errors on every screen and action; uncaught and provider errors logged.

**D-115 Diagnostics completed.** Frames against the display's budget, import benchmark, database facts, Export logs.

**D-116 Releases.** Tag, pubspec and CHANGELOG must agree; notes from `CHANGELOG.md`.

**D-117 Performance pass.** All Linux AOT numbers within target (drill: 0 of 626 frames over the build budget across 20 lines, latency p95 280 ms).

Device checklist (Eli), still open: record the Diagnostics numbers on the phone and Windows (release build); open a `.pgn` from the phone's file manager; install the tagged release APK over the test build and check that the data stays. Before the first tag: add the repository secrets `ANDROID_KEYSTORE_BASE64` and `ANDROID_KEY_PROPERTIES` (and the three Google OAuth ids for sync), then push `v0.1.0`.


## G0 (drill eval bar)

**D-118 Drill eval bar.** Toggle in the drill app bar and Settings → Training, off by default; one short low-priority search per position, cached.
