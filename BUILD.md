Run `dart format lib test`, `flutter analyze --fatal-infos`, and `flutter test` when making changes.

## Spec

Offline workout logbook. Not a trainer: no advice, no calories, no
predictions, no wearables, no camera, no leaderboards, no internet.

Tables (already created in Phase 1, do not alter):
- workout_plans(id PK AI, title TEXT NN, equipmentTag TEXT NN, planNote TEXT,
  effortPreference INTEGER NN 1-5)
- training_logs(id PK AI, workoutId INTEGER NN REFERENCES workout_plans(id)
  ON DELETE CASCADE, sessionKey TEXT NN, exerciseLabel TEXT NN,
  repetitions INTEGER NN >0, loggedAt TEXT NN ISO, sessionFinished INTEGER NN 0/1)

Fixed lists live in models: `equipmentTags` = None, Dumbbells, Resistance
Band, Mat. `exerciseLabels` = Push-ups, Squats, Lunges, Curls, Plank,
Jumping Jacks. Neither is a table.

Core rule, sets are not sessions: every set in one workout shares one
sessionKey, generated when Start is pressed (epoch milliseconds string).
Workout count = COUNT(DISTINCT sessionKey) WHERE sessionFinished = 1.
Never count rows.

Reps validator is a pure function in lib/helper/validators.dart:
`String? validateReps(String? raw)` returns null or an error message; whole
number 1-999 only, rejects 0, negatives, text, blanks. Same function used
by the workout screen and the history edit dialog.

## T0 — database and models
lib/models/workout_plan.dart and training_log.dart with the field sets from
the spec, `const` constructors, `fromMap`, `toMap({bool includeId = false})`,
`copyWith`, and the two fixed lists (`equipmentTags`, `exerciseLabels`) as
top-level consts. `sessionFinished` is a Dart `bool`, converted from and to
`int` inside the mappers only.

lib/db/database_helper.dart: singleton, `Future<Database> get database`,
private `_open()`, plus `Future<Database> openAt(String path)` so tests can
open a temp file. onConfigure runs `PRAGMA foreign_keys = ON`. onCreate
creates both tables with the cascade foreign key, an index on
`training_logs(sessionKey)` and one on `training_logs(workoutId)`, then seeds
three plans in a batch. Seed lives in onCreate only.

main.dart opens the database before runApp and logs the plan count with
`debugPrint`.
Commit: `add models and database schema with seed data`

## T1 — bottom navigation
lib/screens/ root with Scaffold + NavigationBar, three tabs: Plans, History,
Settings. The Plans tab body is the Catalog. Workout and Create/Edit are
pushed routes. Five screen files with placeholder bodies. Delete
test/widget_test.dart (it tests the removed counter). Commit: `add bottom
navigation and five screen shells`

## T2 — shared widgets
lib/widgets/: workout_card.dart (StatelessWidget WorkoutCard), set_row.dart
(StatelessWidget SetRow), stat_tile.dart, empty_state.dart. Semantics on
every tappable. Commit: `add reusable card, row, tile and empty state widgets`

## T3 — plan CRUD
Catalog: ListView of WorkoutCard from DB, filter chips All + each tag,
"Workouts finished: N", empty state "Add a plan first.", "+ New Plan" FAB.
Create/Edit form: title 1-40 required, equipment dropdown, note, effort
Slider 1-5 labelled "1 Easy" to "5 Hard", Save/Cancel. Edit mode adds Delete
with AlertDialog "Delete <title> and its <N> logged sets?" where N counts
rows, then cascade. Commit: `add plan catalog, filter, form and cascade delete`

## T4 — workout flow
Shows plan info and effort. Start generates sessionKey. Exercise dropdown,
reps field with inline validator, "Log set" disabled while writing. Live
summary "<n> sets · <n> reps". Finish sets sessionFinished = 1 for the
session inside a transaction, guarded by a bool so the last set is never
duplicated. Reset confirms then deletes only unfinished sets of the current
session. Edit Plan button. Commit: `add workout session start, log and finish`

## T5 — history
Group by sessionKey, newest first. Header per group: date + plan title.
Each row a SetRow with Edit (dialog: exercise dropdown + reps field, same
validator) and Delete. Dismissible AND visible Delete button, both confirm.
Totals top: workouts finished, total reps, recalculated after every mutation.
Empty state "No sessions yet." Commit: `add history grouping, set edit and delete`

## T6 — settings
Default effort slider, preferred equipment dropdown with "No preference",
dark mode switch, Gear Match visibility switch. SharedPreferences, load on
startup. Commit: `add settings persistence and dark mode`

## T7 — gear match
lib/helper/gear_match.dart, pure functions, no Flutter imports.

`GearSuggestion? suggestPlan({String? preference, required List<WorkoutPlan>
plans, int? lastFinishedWorkoutId})`
Score +2 if plan.equipmentTag == preference, +1 if plan.id !=
lastFinishedWorkoutId. No preference skips +2, no history skips +1. Sort
score desc, ties by lower id. No plans returns null.
Return the winning plan plus a reason string built from the points awarded.

`WorkoutPlan? baselineSuggestion({String? preference, required List<WorkoutPlan>
plans})` equipment match only, ties by lower id.

Card on Catalog, labelled "Suggested by simple rules". Text: "Try <title>:
+2 matches your equipment, +1 different from last time." Buttons "View plan"
and "Not now" (hide until next launch). Never autostarts.

test/gear_match_test.dart, five cases: normal (pref None, A None not last
scores 3, B None last scores 2, C Dumbbells scores 1, expect A); no plans
and separately no history; tie broken by lower id; counterexample (pref
Dumbbells, user wants a Mat plan, expect Mat ranked below Dumbbells).
Commit: `add gear match helper with unit tests`

## T8 — AI_FEATURE.md
Purpose, inputs, scoring rules, baseline, a table of the five cases with ID /
inputs / expected / actual / pass-fail, one limitation, and why rules beat
nearest-neighbor here. Commit: `add gear match design note`

## T9 — acceptance test
Add `sqflite_common_ffi` as a dev_dependency. test/acceptance_test.dart:
`setUpAll(sqfliteFfiInit)`, `databaseFactory = databaseFactoryFfi`, open a
temp file through `DatabaseHelper.instance.openAt`. Assert, using
`COUNT(DISTINCT sessionKey) WHERE sessionFinished = 1`:
- three sets sharing a sessionKey with sessionFinished 1 → 1
- delete one set → still 1
- delete the remaining two → 0
- delete the parent plan → 0 (proves the cascade)
- close and reopen the same file → values intact

Then manual on the emulator: `adb shell cmd connectivity airplane-mode
enable`, log a session, force-stop, relaunch, confirm the session still
lists. Report pass/fail per step.
Commit: `add acceptance test for session counting`

## Done when
`flutter analyze --fatal-infos` is clean, `flutter test` passes all five
gear_match cases, and T9 reports all five acceptance steps passing. Then
print the full `git log --oneline` and stop.
