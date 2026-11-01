# Project One Proposal: Movement Quest

CSC 4360/6360 - Mobile App Development

| Item | Details |
| --- | --- |
| Student | Mario |
| Student ID | 002889038 |
| Team | Team Fitness - solo project |
| Pathway | Undergraduate |
| Proposal date | October 31, 2026 |
| Topic | Movement Quest - offline workout logbook |
| GitHub | https://github.com/ikmroadrunnerllc-cmd/ProjectOne |
| Repository access | Private; instructor access still needs confirmation |
| ClickUp | Board URL pending |

## 1. Reason for the revised proposal

My earlier Trail Tales proposal included route tracking and hazard notes. Those features did not match the official topic restrictions described in my original proposal. I have switched to Movement Quest and limited the project to an offline workout log. It will not include GPS, navigation, health advice, or safety recommendations.

## 2. Project summary and user stories

Movement Quest lets a user save workout plans, record exercise sets, and review completed workouts. It keeps records on the phone using SQLite and saves preferences with SharedPreferences. The app does not need an account, cloud database, or internet connection.

- As a user, I want to filter plans by equipment so I can find a plan I can do.
- As a user, I want to record an exercise and its repetitions during a workout so I have a useful history.
- As a user, I want to correct or delete a set and see an accurate count of finished workouts.

The scope excludes calories, medical predictions, prescribed training, wearables, camera features, GPS, and leaderboards. The effort setting is a personal preference, not an assessment of fitness or readiness.

## 3. Five core screens

| Screen | Main functions |
| --- | --- |
| Catalog / Plans | Plan cards, equipment filter, finished-workout count, Gear Match card, and New Plan button. |
| Create / Edit Plan | Required title, equipment tag, optional note, effort slider from 1 to 5, and save. Existing plans can be deleted with confirmation. |
| Workout | Start a session, select an exercise, enter repetitions, log sets, then Finish or Reset. |
| History | Sets grouped by session, exercise and repetitions editing, delete button or swipe, and totals. |
| Settings | Default effort, preferred equipment, Gear Match switch, and dark mode, saved locally. |

<!-- pagebreak -->

## 4. Navigation and interaction plan

Plans, History, and Settings are tabs on the bottom navigation bar. Selecting a plan opens Workout. New Plan and Edit Plan open the same form. Save returns to the previous screen; Back returns without creating a new plan.

| Starting point | Action | Destination or result |
| --- | --- | --- |
| Plans | New Plan | Create / Edit Plan form |
| Plans | Tap a plan or View plan | Workout for that plan; no session starts automatically |
| Workout | Edit Plan | Create / Edit Plan form with saved values |
| Workout | Start, log sets, Finish | Session saved as finished; totals refresh when the relevant tab reloads |
| Workout | Reset, then confirm | Only unfinished sets for the current session are removed |
| History | Edit or delete a set | Stored record changes and displayed totals refresh |
| Any main tab | Select a bottom tab | Plans, History, or Settings |

The plan list shows an empty state when there are no plans. History shows a separate empty state when no sets have been recorded. Save actions show validation errors or a recoverable failure message. Delete and Reset require confirmation. Edit and delete icon buttons have screen-reader labels; swipe deletion has a visible button alternative.

## 5. Data model and local storage

| Entity | Fields |
| --- | --- |
| WorkoutPlan | id: integer primary key; title: required text; equipmentTag: required text; planNote: optional text; effortPreference: integer from 1 to 5. |
| TrainingLog | id: integer primary key; workoutId: foreign key to WorkoutPlan; sessionKey: required text; exerciseLabel: required text; repetitions: positive integer; loggedAt: timestamp text; sessionFinished: 0 or 1. |

Equipment choices are None, Dumbbells, Resistance Band, and Mat. Exercise choices are Push-ups, Squats, Lunges, Curls, Plank, and Jumping Jacks. These lists are bundled with the app rather than fetched online. Repetition input must be a whole number from 1 to 999; an empty title is rejected.

Both entities support create, read, update, and delete operations. Deleting a plan also deletes its sets through a foreign-key cascade. A confirmation dialog shows how many sets will be removed. SQLite stores plans and sets; SharedPreferences stores default effort, preferred equipment, helper visibility, and theme choice.

## 6. Main challenge: sets are not sessions

All sets entered after one Start action share a sessionKey. Finish marks those rows as finished. The workout count uses distinct session keys with sessionFinished = 1, so three sets in one session count as one workout. Reset removes only unfinished rows for the active session and leaves completed history alone.

Acceptance check: finish one session with three sets and confirm the workout count is 1. Delete one set and confirm it stays 1. Delete the remaining sets and confirm it becomes 0. Restart the app and verify that saved records and preferences persist. This check is planned verification, not a claim that device testing has already passed.

<!-- pagebreak -->

## 7. Smart helper: Gear Match

Gear Match suggests a saved plan on the Plans tab using fixed rules. It does not predict health outcomes or start a workout. The card is labeled Suggested by simple rules and offers View plan and Not now. The user can disable it in Settings.

| Decision | Rule |
| --- | --- |
| Equipment match | Add 2 points when a plan matches the saved equipment preference. Skip this rule when no preference is set. |
| Variety | Add 1 point when a plan differs from the last finished plan. Skip this rule when there is no finished workout. |
| Tie | Choose the plan with the lower database ID. |
| No plans | Return no suggestion and show no suggestion card. |
| Explanation | Show the awarded points, such as +2 matches your equipment. |
| Baseline | Equipment match only, with the same lower-ID tie rule. |

The helper reads only saved plans, the equipment preference, and the last finished workout. A limitation is that a saved preference can disagree with what the user wants today. For example, a Dumbbells preference can rank a Dumbbells plan above a Mat plan even when the user currently wants Mat. Not now, manual selection, and changing the preference give the user control.

I chose rules over nearest-neighbor matching because the app starts with little history and categorical equipment choices. The two rules are easy to check by hand and compare with an equipment-only baseline. The current repository contains helper, settings, and repetition-validator unit tests. Device testing and any additional cases below still need recorded results.

## 8. Evaluation and test plan

| Case | Input or action | Expected outcome |
| --- | --- | --- |
| Normal helper case | Preference None; plans 1 and 2 use None; plan 3 uses Dumbbells; last plan is 2. | Plan 1 wins with 3 points; explanation shows both rules. |
| No data | No saved plans. | No suggestion; no crash. |
| No history | Preference Mat; plan 2 uses Mat; no finished workout. | Plan 2 gets 2 points; no variety point. |
| Tie | Plans 4 and 7 both match and differ from last plan 9. | Plan 4 wins by lower ID. |
| Invalid form input | Blank title; reps 0, -1, text, or 1000. | Relevant validator rejects the input without saving it. |
| Counterexample | Preference Dumbbells; user wants Mat today; last plan uses Dumbbells. | Record that the rules may still choose Dumbbells and explain the limitation. |
| Session count and cascade | Finish three sets; delete sets; then delete a plan with logs. | Count sessions correctly and remove dependent logs only after confirmation. |
| Offline and restart | Use airplane mode on two devices or emulators; save data, close, and reopen. | Plans, sets, and preferences remain available without network access. |
| Accessibility and recovery | Large text, screen-reader controls, repeated Save taps, and a simulated write failure. | Usable layout, named controls, no duplicate writes, and a recoverable message. |

For each run I will record inputs, expected and actual results, pass/fail, and any correction. Helper cases will also record the baseline result. Manual and device results are pending; this proposal does not treat existing test definitions as proof of a successful run.

<!-- pagebreak -->

## 9. Solo ownership and project management

I am responsible for the interface, SQLite data layer, workout flow, Gear Match, testing, and submission documents. ClickUp will track tasks with an owner, acceptance criteria, target date, status, and a related commit or test record. The workflow is Backlog, To Do, In Progress, Review, and Done, with no more than two tasks in progress at once.

The repository is private. Instructor access needs confirmation before review. The ClickUp board URL and a readable, dated board snapshot still need to be supplied. Each completed task will link to its implementation changes and verification notes.

## 10. Revised milestones

The source proposal listed October 18, 21, 24, 26, and 28 deadlines. Those dates precede this October 31 revision and should not be presented as future deadlines or completed work. The sequence below is proposed; calendar dates need instructor confirmation.

| Milestone | Deliverable and acceptance criteria | Date |
| --- | --- | --- |
| Proposal approval | Revised proposal, correct topic scope, repository access, ClickUp link, and acknowledgment requirements confirmed. | Pending instructor agreement |
| UI and navigation | All five screens reachable; forms and empty states usable; initial peer feedback recorded. | Pending instructor agreement |
| Data and workout flow | CRUD for both entities, confirmed cascade deletion, session counting, Finish/Reset, and persistent preferences verified. | Pending instructor agreement |
| Helper and testing | Gear Match compared with baseline; normal, empty, invalid, tie, and counterexample cases documented; offline/restart checks on two devices or emulators. | Pending instructor agreement |
| Revision and submission | Fix observed issues; record a peer-driven improvement; assemble build, report, feature note, and required presentation materials. | Pending instructor agreement |

## 11. Review and iteration

I will ask two peers to create a plan, log and finish a three-set workout, and correct a recorded set. I will record whether they complete each task, where they hesitate, and what they find confusing. I will revise a concrete issue, capture the before/after behavior, and repeat the affected task. Peer review has not been claimed as completed in this proposal.

## 12. Submission checklist and acknowledgment

| Item | Current status |
| --- | --- |
| Project title, student ID, team name, and pathway | Filled from the source proposal. Full student name and exact course section still need confirmation. |
| Repository URL | Filled; repository is private. Instructor access needs confirmation. |
| ClickUp link and dated snapshot | Pending; no board URL or snapshot was available. |
| Signed statement | The source proposal says it is attached separately; the signed attachment was not available for verification. |
| Revised due dates | Pending instructor agreement. |
| Manual test evidence and peer feedback | To be recorded; no unverified passes or signatures have been added. |

This revision replaces the unfinished multi-member proposal with a solo-project plan. It describes the current project structure and the checks still required before submission.
