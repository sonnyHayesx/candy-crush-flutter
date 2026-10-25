# Campaign readiness audit — 25 October 2026

## Verified source state

- Exactly 100 levels, numbered consecutively, with unchanged app JSON schema.
- 100 distinct terrain layouts; every playable cell belongs to one connected area.
- All 100 levels have a winning action sequence replayed through the production
  controller and animation resolver. Final calibration validation: 100 seeds per
  level per policy, three policies, **30,000 trials**; command passed.
- Independent follow-up: **6,000 trials** on 20 new seeds per policy per level
  (`SEED_BASE=900000`); all 100 levels again have replayed winning witnesses.
  Evidence: `level_holdout_results.json`. No tuning used these follow-up seeds.
- All **42 Flutter tests pass**, including all 100 complete game screens at
  320×568, 412×915 and 800×360 logical pixels. Tests check positive tile sizes,
  cell positions, screen bounds and separation from the objective panel.
- `flutter analyze`: no issues. `flutter pub get --enforce-lockfile`: passed.
- Progress migration, lazy access through level 100 and final-level completion
  behavior are covered by automated tests.

Validated `assets/levels.json` SHA-256:
`51C853FF9BD6FBA02DA1E8CFEA94DA5890F8954B641F198FFB02F121C39E673B`.
Environment: Flutter 3.47.7, Dart 3.13.5, Windows; framework revision abaf9c5237.

## Corrections made during this audit

The previous generation left isolated edge cells on ten family-6 boards and
level 92. The generator now removes disconnected decorative islands. A stripe
goal tutorial appears at level 18 before later compound goals. The old geometry-
dependent engine tests now use explicit fixtures. Landscape previously centered
the board under the HUD; controls now occupy a separate left column, with the
board on the right and its width constrained to the remaining space.

The first 30,000-trial baseline had no winning witness for levels 65, 70, 75, 79,
80, 83, 88, 89, 92, 93, 97, 98 and 99. These were unverified, not proven
mathematically impossible. Measured quota corrections are preserved in
`tool/level_balance.json`; the final full run found replayable wins for all 100.

## Difficulty and evidence limits

Chapter mean average-policy win rates are 99.1%, 95.2%, 89.0%, 76.8%, 72.3%,
67.4%, 60.2%, 56.5%, 52.0% and 41.3%. This supports increasing aggregate
difficulty, not monotonic difficulty at every adjacent level. Individual rates,
remaining moves, failures, seeds and traces are in `level_validation_results.json`
and `level_difficulty_report.md`. Policies are synthetic and uncalibrated against
humans. The same fixed seeds were used to calibrate quotas and measure that run.

These checks establish reachable wins and tested layout bounds. They do not prove
that every random deal is winnable, that all device/font/safe-area configurations
render identically, or that humans find the campaign enjoyable and fair. Physical
device playtesting and updated signed-binary acceptance remain outstanding.
The existing APK/AAB described in `RELEASE_RESULT.md` predate this campaign.

Research covered eight games and the four requested papers. Twelve YouTube
gameplay/tutorial metadata records were reviewed; **zero videos were visually
inspected** because frames/transcripts were inaccessible. See the research report
for exact access limitations rather than treating metadata as watched gameplay.

## Reproduce

1. `dart run tool/generate_levels.dart`
2. `flutter test --reporter expanded`
3. `flutter test tool/validate_levels_test.dart --dart-define=TRIALS=100 --reporter expanded`
4. `dart run tool/report_level_validation.dart`
5. `flutter analyze`

Independent seed check: `flutter test tool/validate_levels_test.dart --dart-define=TRIALS=20 --dart-define=SEED_BASE=900000 --dart-define=OUTPUT=docs/level_holdout_results.json --reporter expanded`.

Do not rerun `calibrate_levels.dart` against already calibrated results; the
recorded balance file deliberately prevents accidental compounding of reductions.
