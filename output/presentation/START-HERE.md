# Movement Quest rehearsal

## Put the script on screen

Double-click `teleprompter.html` in this folder. Keep `teleprompter.js` beside it.
It opens locally in Chrome or Edge; no account or upload is needed.

1. Place the presenter near your camera, on a second display or beside the emulator.
2. Click **Start scrolling**. Adjust Speed and Text until you can read comfortably.
3. Click inside the reading area to use Space for start/pause, Left/Right for
   sections, Home to restart a section, and Escape to pause. Buttons and text
   fields keep their normal keyboard behavior.
4. Read the large text aloud. Gold action cues are instructions, not narration.
5. Pause to operate the app or show code. Use Next section when ready. The timer
   measures active reading time and pauses with scrolling; it is not a recording timer.
6. Use **Edit section** to personalize the words or add your curated answers.
   Changes stay in this browser. Use **Download script** to keep a portable copy.

Record the emulator/app window rather than the entire desktop so the presenter
doesn't appear in your submission. Browser keyboard shortcuts only work while
the presenter has focus; they are not global controls. Practice switching windows
before recording. Use your recording software's timer for total video length.

## Launch a fresh demo take

From a PowerShell terminal in the project root, with an Android emulator running:

```powershell
flutter devices
.\tools\start-demo.ps1 -Fresh -Device emulator-5554
```

Replace `emulator-5554` with the ID printed by `flutter devices`. If Windows
blocks local scripts, run the equivalent Flutter command directly:

```powershell
flutter run -d emulator-5554 --dart-define=DEMO_MODE=true --dart-define=DEMO_RESET=take-1
```

Use a different reset value for a new take. Reusing the same value preserves
changes after the first reset. Do not change it during the persistence demonstration.
The reset happens on app startup for a new token, not on hot reload.

To build an installable debug demo APK instead:

```powershell
.\tools\start-demo.ps1 -BuildApk -Fresh
```

Flutter writes it to `build/app/outputs/flutter-apk/app-debug.apk`. A normal
`flutter run` without demo defines selects the normal data again. Switching
builds installs the selected build in the same Android app; the database files
and preference keys remain separate. Don't uninstall the app or use Clear storage
if you want to preserve normal and demo data.

## Your sample data and expected results

| Step | Finished workouts | Total reps |
| --- | --- | --- |
| Fresh demo: Morning Bodyweight has Push-ups 8 and Squats 10 | 1 | 18 |
| Create Leg Day: Mat, effort 3; finish Push-ups 12, Squats 14, Push-ups 10 | 2 | 54 |
| Edit Leg Day's last 10 reps to 11 | 2 | 55 |
| Delete only the three Leg Day sets | 1 | 18 |
| Finish Curls 6 under Cascade Demo | 2 | 24 |
| Delete Cascade Demo and confirm its one dependent set | 1 | 18 |

There are four starting plans: Morning Bodyweight, Dumbbell Basics, Mat Core,
and Cascade Demo. Leg Day is intentionally not precreated. Reset an unfinished
Leg Day session before the history-deletion steps to demonstrate that finished
history is preserved. Keep the original Morning Bodyweight session throughout.

## Check before recording

- Fill the Curated questions section with the instructor's exact questions and
  your answers. The question IDs alone do not identify their wording.
- Run `flutter analyze --fatal-infos` and `flutter test`; show actual results.
- On the same installed demo build, enable airplane mode, force-stop, and reopen
  from the launcher. Confirm history and settings. A fresh run command would
  create a new take only if its reset token changes.
- Repeat the offline/restart check on a second device or emulator. Each has its
  own local database; there is no sync. Record results instead of assuming a pass.
- Review the original assignment rubric, signed statement, ClickUp evidence,
  final report/build/presentation requirements, and instructor repository access.

The full spoken text is in the presenter and can be downloaded as a text file.
An initial text copy is also included as `presentation-script.txt` in this folder.
The time hints include app actions and code walkthroughs, not just reading.
Rehearse once from beginning to end before attempting a final recording.
