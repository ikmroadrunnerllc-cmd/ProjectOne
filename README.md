# Movement Quest

Movement Quest is an offline workout logbook for CSC 4360 Project One.
Team Fitness is a solo team: Mario Leonel Gutierrez Espinal.

The app saves workout plans, reps and optional weights. Users can edit or
delete plans and sets, filter plans by equipment, and review finished workouts.
Settings include default effort, preferred equipment, dark mode and Gear Match.
SQLite stores the workout records. SharedPreferences stores settings.

## Run the app

Install Flutter and the Android SDK. Connect an Android phone or start an emulator.
From the project folder, run:

```text
flutter pub get
flutter run
```

To check the code and tests:

```text
flutter analyze --fatal-infos
flutter test
```

To build the normal release APK:

```text
flutter build apk --release
```

The result is `build/app/outputs/flutter-apk/app-release.apk`. The build folder
is excluded from Git. A local submission copy is at `output/apk/Movement_Quest.apk`.
Only the APK is needed to install the app on Android.

For a separate rehearsal database, run `tools/start-demo.ps1 -Fresh`.
The release build command above does not enable demo mode.

## Design and testing

Screens are in `lib/screens/`, models in `lib/models/`, and shared widgets in
`lib/widgets/`. `lib/db/database_helper.dart` owns the database calls.
`lib/helper/validators.dart` checks form input.

Gear Match uses fixed scoring rules to suggest a plan. Its explanation,
baseline, test cases and limits are in [AI_FEATURE.md](AI_FEATURE.md).
Development assistance is described in [AI_Usage_Log.md](AI_Usage_Log.md).

The last verified run on October 31, 2026 passed analysis and all 20 tests.
The normal release APK was installed and opened on emulator-5554.
The earlier airplane-mode restart check used the demo build on that emulator.
A second-device check and a navigation-away-during-save test are still pending.

## Documents

The plain-text report is [docs/Movement_Quest_Final_Report.txt](docs/Movement_Quest_Final_Report.txt).
Its printable copy is [output/pdf/Movement_Quest_Final_Report.pdf](output/pdf/Movement_Quest_Final_Report.pdf).

The simplified proposal is [docs/Movement_Quest_Proposal_Simple_Draft.txt](docs/Movement_Quest_Proposal_Simple_Draft.txt),
with a [PDF copy](output/pdf/Movement_Quest_Proposal_Simple_Draft.pdf).
This is a new wording draft. The earlier proposal text remains at
`movement_quest_proposal.md`. Superseded proposal PDFs have been removed.
Instructor approval of the new draft has not been verified.

The presentation is `output/presentation/Movement_Quest_Basic.pptx`.
The matching PDF is in the same folder. The questions-only Word document is
`output/presentation/TeamFitness_Project1_SelectedQuestions.docx`; a PDF copy
is also in that folder.

## Submission links and remaining evidence

Repository: https://github.com/ikmroadrunnerllc-cmd/ProjectOne

The repository is private. Instructor access still needs verification.
The video is finished according to the student; its YouTube URL has not been
provided for this README or checked for playback.

ClickUp board URL: not yet provided.
Required evidence PDF path: `Kanban_Contribution_Evidence.pdf` at the repository
root. That file has not been added. It needs the board policies, actual dated
snapshots, a completed task-to-code/test trace, and a flow reflection.

The approved proposal version and final iCollege upload receipt still need
to be checked. The simple slide deck also needs the required
UML diagram, explicit pseudocode, transitions/animations and ClickUp trace.
