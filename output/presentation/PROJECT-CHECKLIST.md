# Project verification before recording

Checked October 31, 2026 against the repository's BUILD.md, proposal, and source.
The instructor's original rubric and exact curated questions were not available,
so this is not certification that every course requirement has been met.

| Area | Result |
| --- | --- |
| Flutter analysis | Passed with no issues. |
| Automated tests | All 15 passed: 5 Gear Match, 3 preferences, 2 input validation, 5 database/demo acceptance. |
| Real SQLite acceptance | Verified distinct session counts after set deletion, cascade deletion, unfinished-session reset isolation, and file close/reopen persistence. |
| Demo isolation | Verified separate database, separate preferences, one-time seed, persistent rehearsal edits, and reset-token behavior without altering normal records. |
| Android demo APK | Debug build succeeded with DEMO_MODE enabled. Located at build/app/outputs/flutter-apk/app-debug.apk. |
| Presenter controls | Browser checks cover auto-scroll, pause, Escape while a button is focused, Space, section navigation, editable text persistence, font controls and focus view. |
| Core features | Source contains five screen roles, CRUD for both entities, meaningful effort slider, filters, history aggregates, confirmed cascade deletion, settings, and Gear Match explanations/opt-out. |
| Device offline/restart | Passed on emulator-5554 (Pixel_Smiley): rendered Plans screen, enabled airplane mode, force-stopped/relaunched, verified 4 plans / 1 session / 18 reps, and restored the previous network state. A second device or emulator and a recorded settings-persistence walkthrough are still needed. |
| Curated questions | Exact wording and final answers still needed. Edit the presenter's questions section before recording. |
| Submission requirements | Confirm original rubric, instructor access to private repository, ClickUp URL/snapshot, signed statement, final report, and any slides/video/build requirements. |

All sample workouts are fictional. Do not present an unperformed device test,
unverified attachment, or draft answer as a completed requirement.

No commits or pushes were performed for the rehearsal setup.
