# Gear Match

## Purpose

Gear Match suggests one plan at the top of the Plans tab so the user doesn't
have to pick from the whole list each time. It applies a few fixed rules. It
isn't machine learning, it gives no training advice, and it never starts a
workout. "View plan" only opens the plan.

The card is labeled "Suggested by simple rules" and has two buttons: "View
plan" and "Not now". "Not now" hides it until the app is restarted, and the
Show Gear Match switch in Settings turns it off completely.

## Inputs

- **Preferred equipment** from Settings: one of None, Barbell, Dumbbells, Resistance
  Band or Mat, or "No preference".
- **Plans**: every row in `workout_plans`.
- **Last finished plan**: the `workoutId` of the newest finished session,
  meaning the highest sessionKey with `sessionFinished = 1`. It is null
  before the first workout is finished.

All three come from the device. Nothing leaves the phone.

## Scoring rules

Code: `suggestPlan` in `lib/helper/gear_match.dart`, a pure function with no
Flutter imports.

| Rule | Points | Skipped when |
|---|---|---|
| `plan.equipmentTag == preference` | +2 | no preference is set |
| `plan.id != lastFinishedWorkoutId` | +1 | no workout has been finished |

Plans are sorted by score, highest first, and ties go to the lower id. With
no plans it returns null and the card doesn't show. The card text is built
from the points the winning plan got, for example:

> Try Morning Bodyweight: +2 matches your equipment, +1 different from last time.

## Baseline

`baselineSuggestion` uses only the equipment rule, with ties going to the
lower id. It's there to compare against: the +1 rule is the only thing
`suggestPlan` adds, and it keeps the user from being sent back to the plan
they just finished.

## Test cases

From `test/gear_match_test.dart`, run with
`flutter test test/gear_match_test.dart` on 2026-10-31.

| ID | Inputs | Expected | Actual | Result |
|---|---|---|---|---|
| 1 Normal | pref None; A(1, None), B(2, None, last), C(3, Dumbbells) | A, score 3 (B 2, C 1); baseline also A | A, score 3, reason "+2 matches your equipment, +1 different from last time"; baseline A | Pass |
| 2 No plans | pref None; no plans | null from both functions | null, null | Pass |
| 3 No history | pref Mat; 1 None, 2 Mat; no finished workout | plan 2, score 2, +1 skipped | plan 2, score 2, reason "+2 matches your equipment" | Pass |
| 4 Tie | pref Dumbbells; 7 and 4 both Dumbbells; last = 9 | plan 4 (both score 3) | plan 4, score 3 | Pass |
| 5 Counterexample | pref Dumbbells; Mat(1), Dumbbells(2, last); user wants Mat today | Mat ranked below Dumbbells | Dumbbells, score 2; Mat scores 1 | Pass |

## Limitation

The rules only know the saved preference and the last session. They don't
know what the user wants today. Case 5 shows this: someone who wants a Mat
workout still gets the Dumbbells plan, because that is their saved
preference and the +2 outweighs the +1. They can tap "Not now" or change
the preference in Settings.

## Why rules and not nearest-neighbor

- **Too little data.** A user has a handful of plans and a short history.
  Nearest-neighbor needs enough past choices to find similar ones, and on day
  one there are none.
- **Explainable.** Every point appears in the card text, so the user can see
  exactly why a plan was picked. A neighbor distance can't be shown that way.
- **Offline and testable.** The rules are two comparisons in a pure function.
  Each case above is an exact expected answer, not a score threshold.
- **Few signals.** There are only two inputs (equipment and last plan), and
  two weighted rules cover both directly.
