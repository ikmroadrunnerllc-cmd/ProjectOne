'use strict';

const sections = [
  { title: 'Introduction and question set', time: '0:00–2:00', cue: 'Before recording: run .\\tools\\start-demo.ps1 -Fresh. Expect 4 plans, Workouts finished: 1, 18 total reps. Record only the emulator and VS Code, never this window. Say each question ID out loud when you reach it.', text: `Hi, I'm Mario, and this is my Project One for CSC 4360, Movement Quest. I'm a solo team called Team Fitness, so I built and I'm explaining every part myself.

Movement Quest is an offline workout logbook. You save workout plans, log each set while you train, including the weight you used, and look back at your history. It's a logbook, not a trainer. It doesn't give health or exercise advice, and everything is stored on the phone.

The sample history in this demo is fictional and lives in a separate demo database. It starts with one finished workout of two sets and eighteen reps.

I'm answering twelve curated questions. The five required ones are I1, I2, D1, D2 and R4. I'm adding A1 and A2 for architecture, D4 and D5 for local data, T1 and T2 for testing, and R5 for reflection. I'll say each ID when I get to it.` },

  { title: 'Why I changed topics', time: '2:00–2:30', cue: 'Stay on the Plans screen.', text: `I first proposed Trail Tales, but my version didn't match the brief. It described route tracking and safety-style warnings, which the brief doesn't allow. So I switched to Movement Quest and followed its brief. The new scope is a local logbook that records what the user enters, with no health or safety recommendations.` },

  { title: 'Plans, filter and validation (I2, D1, D5)', time: '2:30–4:30', cue: 'Plans: point at "Workouts finished: 1" and the Gear Match card. Tap the Barbell chip (no plans yet), then All. New Plan → tap Save with an empty title → error shows. Type Barbell Day, Equipment Barbell, drag effort to 4, Save. Tap Barbell chip again: Barbell Day shows. Tap All.', text: `This is the Plans screen. It's my catalog and home screen. At the top it shows how many workouts I've finished, and under it is my smart helper, Gear Match, which I'll come back to.

These chips filter the list by equipment. I added Barbell for bench press and squats. Right now no plan uses it, so the list says so instead of going blank.

For I2 and D1, I'll create a plan. If I tap Save with no title, the form stops me and shows "Enter a title." Nothing is written to the database. I'll call it Barbell Day, pick Barbell, and set the effort slider to four.

The slider is my meaningful control. Its value is saved with the plan as the effort level from one to five. While I drag, the number is only screen state. It's saved when I press Save.

Now the Barbell filter shows Barbell Day. That's create and read for plans. For D5, filtering only changes what's displayed. It never changes the saved data.` },

  { title: 'Start, log and finish (I1, I2, T2)', time: '4:30–7:00', cue: 'Open Barbell Day → Start. Exercise Bench Press. Reps 0 → error. Reps 5, Weight 0 → error. Weight 135 → Log set. Squats 8 × 185 → Log set. Bench Press 5 × 135 → Log set. Point at "3 sets · 18 reps". Tap Finish twice quickly. Back to Plans: count is 2, not 3 or 4.', text: `I'll open Barbell Day and press Start. Start creates a session key, a timestamp that every set in this workout will share.

For validation: if I enter zero reps, the form says reps must be from one to nine hundred ninety-nine. Weight is optional, since push-ups and planks have none. But if I type zero, it says weight must be above zero. It accepts decimals like two and a half, so it works for a barbell, dumbbells or a band.

I'll log bench press, five reps at one hundred thirty-five pounds. Then squats, eight at one eighty-five. Then bench press again, five at one thirty-five. The weight box stays filled between sets, because you usually repeat the same weight.

The screen updates right away: three sets, eighteen reps. That's I1. This screen is a StatefulWidget, and every Log set calls setState, which rebuilds the list from the current values.

For T2, I'll tap Finish twice, quickly. While a save is running, the buttons are disabled, so the second tap does nothing. When I go back to Plans, the count went from one to two, not three and not four.

That's the main challenge of this topic: sets are not sessions. These three sets share one session key, so they count as one workout.` },

  { title: 'Reset in-progress work (T2)', time: '7:00–7:45', cue: 'Open Barbell Day → Start → Squats 5 × 185 → Log set → Reset → read the dialog → confirm. Open History: still 2 workouts, 36 total reps.', text: `Reset only throws away the workout in progress. I'll start another session, log one set and press Reset.

It asks me to confirm first. Then it deletes only the unfinished rows with this session key. In History, I still have two finished workouts and thirty-six total reps. Finished history is never touched.` },

  { title: 'History: edit and delete (D1, D5)', time: '7:45–9:30', cue: 'History: find the Barbell Day session. Edit the last Bench Press: reps 5 → 6, weight 135 → 140, Save. Point at "6 reps · 140 lb" and Total reps 37. Delete one set with its button (confirm), swipe another left (confirm). Delete the last one. Count back to 1, total 18.', text: `This is History, grouped by session. Each set shows its reps and weight.

For D1, I'll update the child record. I'll edit the last bench press from five reps to six and from one thirty-five to one forty. The row now says six reps, one hundred forty pounds, and the total went from thirty-six to thirty-seven right away. That's D5: the totals are computed from the saved sets every time, so an edit changes them immediately.

Now delete. I can use the Delete button, or swipe for anyone who prefers it. Both ask me to confirm, and both run the same code. After deleting one set, it's still two workouts, because another set from that session remains.

When the last Barbell Day set is gone, the count goes back to one and the total back to eighteen. The sample workout is still there.` },

  { title: 'Plan update and cascade delete (D1)', time: '9:30–10:45', cue: 'Plans → Cascade Demo → Start → Curls 6 → Log set → Finish. Edit Plan → change effort → Save (header updates). Edit Plan → Delete plan → read "Delete Cascade Demo and its 1 logged sets?" → Delete. Plans: count 1, total 18.', text: `To finish D1 for the parent record, I'll use a throwaway plan called Cascade Demo. I'll log and finish one set so it has history.

Update: I'll edit the plan, change its effort and save. The header shows the new value.

Delete: the dialog tells me how many sets will go with it. When I confirm, the database's foreign key with ON DELETE CASCADE removes the plan's training logs too, so no orphaned sets are left. The count is back to one and the total to eighteen.` },

  { title: 'Settings and offline restart (D2)', time: '10:45–12:45', cue: 'Settings: Default effort 4, Preferred equipment Dumbbells, Dark mode ON. Turn on airplane mode. Force-stop the app (swipe it away) and reopen the same app (not -Fresh). Show: dark mode still on, Dumbbells still picked, Plans count 1, History 18 reps, Barbell Day still listed.', text: `Now D2. In Settings I'll set default effort to four, preferred equipment to Dumbbells, and turn on dark mode. Each change is saved as soon as I make it.

I use two kinds of local storage. SQLite holds the records: plans and sets, two related tables. SharedPreferences holds the small settings values. Neither one is a server.

I'll turn on airplane mode, close the app completely and open it again. Dark mode is still on, Dumbbells is still selected, and my plans and history are all here. Nothing was downloaded, because the data never left the phone.

The release build doesn't even request internet permission. GitHub, ClickUp and YouTube are where I keep my code, plan my tasks and post this video. The app never talks to any of them.` },

  { title: 'Widgets in code (I1, I2)', time: '12:45–14:00', cue: 'Switch to VS Code. Show only these 2 snippets. Ctrl+G = jump to a line.\n1. lib › widgets › workout_card.dart, lines 5–35 (I1, StatelessWidget).\n2. lib › screens › workout_screen.dart, Ctrl+G 57: _logSet (I1 StatefulWidget + I2).\nMention SetRow in one sentence. Do not open it.', text: `For I1, WorkoutCard is a StatelessWidget. It gets a plan and draws its title, equipment, effort and note. It holds no state of its own, and I reuse it for every plan in the list. SetRow is the same idea for one set, and I use it on both the Workout and History screens. It's where "five reps, one thirty-five pound" comes from.

The Workout screen is a StatefulWidget because it has to remember things while you use it: the session key, the sets logged so far, the chosen exercise, and whether a save is running.

For I2, the transient values are the text in the boxes, the chosen exercise and the busy flag. They disappear when you leave. What gets saved is the set row in SQLite. In _logSet, the form validates first, then the row is inserted, and only after that does setState add it to the list.` },

  { title: 'Responsibilities and lifecycle (A1, A2)', time: '14:00–15:30', cue: 'No new code here. Stay on workout_screen.dart and just talk.\nOptional: Ctrl+G 33 and point at dispose for A2.\nThe model, insertLog and the validators go on your PowerPoint, not on screen.', text: `For A1, I'll trace one feature through the layers. The screen collects the input and shows results. The TrainingLog model turns a set into a database row with toMap. The DatabaseHelper owns every SQL call. Input rules live in validators.dart, so the Workout screen and the History edit dialog share one rule.

If the widget did everything, the SQL would be copied across screens, the rules could drift apart, and I couldn't unit test them without building a whole screen.

For A2, the screen owns two text controllers, and dispose frees both when the screen closes. Saves are asynchronous. If I leave the screen while a save is running, the code reaches "if not mounted, return" and stops instead of calling setState on a screen that's gone. The row is still saved, so nothing is lost. This guard is in the code. I don't have an automated test that navigates away in the middle of a save.` },

  { title: 'Schema, queries and migration (D1, D4, D5)', time: '15:30–17:00', cue: 'Open lib › db › database_helper.dart. Show only these 4 snippets. Ctrl+G = jump to a line.\n3. Ctrl+G 195: CREATE TABLE training_logs with ON DELETE CASCADE (D1).\n4. Ctrl+G 80: deletePlan, the ? query (D1).\n5. Ctrl+G 95: finishedWorkoutCount, COUNT(DISTINCT sessionKey) (D5).\n6. Ctrl+G 36: version: 2 and onUpgrade (D4).\nMention the upgrade test in one sentence. Do not open it.', text: `The schema has two tables. Training logs reference workout plans by foreign key with ON DELETE CASCADE. Foreign keys are off by default in SQLite, so I turn them on every time the database opens. CHECK constraints reject reps of zero or less, a weight of zero or less, and an effort outside one to five. So even if a screen had a bug, the database would refuse bad data.

Every value goes in through a question mark and whereArgs. I never put user input inside the SQL string.

For D5, the workout count is COUNT DISTINCT on sessionKey, finished rows only. Three rows from one session count as one.

For D4, adding weight was a real schema change. Older installs had version one, with no weight column. The database is now version two, and onUpgrade adds the column with ALTER TABLE. Existing sets keep their data, and their weight is empty, which means bodyweight. This test builds a version one database with a saved set, opens it with the new code, and checks the set is still there.` },

  { title: 'Gear Match helper (R4)', time: '17:00–19:30', cue: 'Start in the app: the Plans card reads "Try Dumbbell Basics: +2 matches your equipment, +1 different from last time." Tap View plan, go back, tap Not now (card hides).\nThen VS Code. Show only this snippet. Ctrl+G = jump to a line.\n7. lib › helper › gear_match.dart, Ctrl+G 52: _score, the +2 and +1 rules.\nThe baseline, tie-break, test table and limitation go on your PowerPoint. Just say them.', text: `For R4, my required smart helper is Gear Match. It uses simple rules, not a trained model, and the card says "Suggested by simple rules."

Its inputs are my preferred equipment from Settings, my saved plans, and the plan I finished last, all read from the phone. A plan gets two points if it matches my equipment and one point if it isn't the plan I did last time. Ties go to the lower id. The card explains the points. Here it says Dumbbell Basics, plus two for matching, plus one for being different from last time.

I stay in control. View plan only opens it and never starts a workout. Not now hides the card, and Settings can turn it off.

It's one pure function, so I tested five case types: a normal case, no plans, no finished workout yet, a tie, and a counterexample. With no plans there's no suggestion, and the screen says "Add a plan first." For invalid data, a saved preference that isn't a real equipment type, like Kettlebell, is ignored instead of trusted. That's tested in the settings tests.

The baseline uses equipment only. The plus one is the only thing my rules add. It matters when two plans match and the one I just did has the lower id. The baseline would send me straight back to it.

The counterexample: my saved preference is Dumbbells, but today I want a light mat session. The rules still pick Dumbbells, because they can't know what I want today. I kept that limitation and documented it rather than guess. I chose rules over nearest-neighbor because a new user has almost no history, and rules can explain every point.` },

  { title: 'Tests and acceptance (T1, T2)', time: '19:30–21:00', cue: 'No code to open. Press Ctrl+Shift+` (backtick, the key under Esc) to open a terminal.\nType: flutter test   then Enter. Wait for "All tests passed!" (20 tests). That is the evidence.\nIf you ran the airplane-mode check on a second emulator, show it now; otherwise say only what you ran.', text: `For T1, this is how my tests map to the requirements. The database tests run on a real SQLite file. They check that deleting sets updates the workout count, that deleting a plan cascades, that reset keeps finished sessions, and that data survives closing and reopening. The weight tests cover saving, editing and clearing a weight, and the upgrade from version one. Unit tests cover Gear Match, the reps and weight validators, and settings save and load. That's twenty tests, and they all pass.

The five-screen flow and offline restart I tested by hand, as you just saw: normal data, the empty filter and invalid input.

For T2, the guarded failures are the double-tap on Finish, invalid reps and weight, and a failed database write. If a write throws, the user sees "Could not save. Try again." and what they typed stays in the form. I didn't hit a real save failure while building, so I'm showing the guard and the code path rather than claiming a bug I didn't have.` },

  { title: 'Next iteration and reflection (R5)', time: '21:00–22:30', cue: 'Show your ClickUp board briefly. Edit this section in your own words before recording.', text: `For R5, one planning choice that created a limitation: I designed the log around reps first and added weight late. The weight box is optional and pounds only, and the app doesn't remind you what you lifted last time.

The first thing I'd change is a small "last time" line under the exercise, like "135 pounds for 5." It would read from the same local table, so it keeps local-only storage and stays within the topic. I'd verify it with a database test that logs two sessions and checks the newest one is shown.

What I learned: put the rules where they can be tested, and let the database protect the data too, not just the form.` },

  { title: 'Closing', time: '22:30–23:00', cue: 'Return to Plans. Stop recording after the last sentence.', text: `To wrap up, Movement Quest has its screens, two related SQLite tables with full CRUD, a start-to-finish workout flow with weights, saved settings, a schema upgrade that keeps old data, and a local helper that explains its choice.

Everything stays on the device and works offline. Thanks for watching.` },
];


const codeBlocks = {
  "8": [
    {
      "file": "lib/widgets/workout_card.dart",
      "lines": "5–35",
      "code": "  5  class WorkoutCard extends StatelessWidget {\n  6    const WorkoutCard({super.key, required this.plan, required this.onTap});\n  7  \n  8    final WorkoutPlan plan;\n  9    final VoidCallback onTap;\n 10  \n 11    @override\n 12    Widget build(BuildContext context) {\n 13      final note = plan.planNote;\n 14      return Semantics(\n 15        button: true,\n 16        label:\n 17            '${plan.title}, ${plan.equipmentTag}, '\n 18            'effort ${plan.effortPreference} of 5',\n 19        onTap: onTap,\n 20        excludeSemantics: true,\n 21        child: Card(\n 22          child: ListTile(\n 23            title: Text(plan.title),\n 24            subtitle: Text(\n 25              [\n 26                '${plan.equipmentTag} · Effort ${plan.effortPreference}/5',\n 27                if (note != null && note.isNotEmpty) note,\n 28              ].join('\\n'),\n 29            ),\n 30            trailing: const Icon(Icons.chevron_right),\n 31            onTap: onTap,\n 32          ),\n 33        ),\n 34      );\n 35    }",
      "what": "A StatelessWidget. WorkoutCard draws one plan as a card: its title, equipment, effort and optional note. It keeps no state of its own. Whatever plan it is given is what it shows, and tapping it opens the Workout screen."
    },
    {
      "file": "lib/screens/workout_screen.dart",
      "lines": "57–82",
      "code": " 57    Future<void> _logSet(String sessionKey) async {\n 58      if (_busy || !_formKey.currentState!.validate()) return;\n 59      setState(() => _busy = true);\n 60  \n 61      final draft = TrainingLog(\n 62        // plans reach this screen from the database, so the id is always set\n 63        workoutId: _plan.id!,\n 64        sessionKey: sessionKey,\n 65        exerciseLabel: _exercise,\n 66        repetitions: int.parse(_reps.text.trim()),\n 67        weight: parseWeight(_weight.text),\n 68        loggedAt: DateTime.now(),\n 69      );\n 70      try {\n 71        final id = await DatabaseHelper.instance.insertLog(draft);\n 72        if (!mounted) return;\n 73        setState(() {\n 74          _sets.add(draft.copyWith(id: id));\n 75          _busy = false;\n 76        });\n 77      } catch (e) {\n 78        debugPrint('log set failed: $e');\n 79        if (!mounted) return;\n 80        setState(() => _busy = false);\n 81        _showSnack('Could not save. Try again.');\n 82      }",
      "what": "Inside a StatefulWidget. _logSet runs when you tap Log set: it validates the form, saves the set, then setState adds it to the list so the screen redraws. If the save fails, you see \"Could not save. Try again.\" and what you typed stays."
    }
  ],
  "10": [
    {
      "file": "lib/db/database_helper.dart",
      "lines": "195–208",
      "code": "195      batch.execute('''\n196        CREATE TABLE training_logs (\n197          id INTEGER PRIMARY KEY AUTOINCREMENT,\n198          workoutId INTEGER NOT NULL\n199            REFERENCES workout_plans(id) ON DELETE CASCADE,\n200          sessionKey TEXT NOT NULL,\n201          exerciseLabel TEXT NOT NULL,\n202          repetitions INTEGER NOT NULL CHECK (repetitions > 0),\n203          $_weightColumn,\n204          loggedAt TEXT NOT NULL,\n205          sessionFinished INTEGER NOT NULL DEFAULT 0\n206            CHECK (sessionFinished IN (0, 1))\n207        )\n208      ''');",
      "what": "The child table. workoutId points to workout_plans.id with ON DELETE CASCADE, so deleting a plan deletes its sets. The CHECK rules make the database refuse zero reps or a zero weight."
    },
    {
      "file": "lib/db/database_helper.dart",
      "lines": "80–84",
      "code": " 80    /// Deletes a plan and, through the foreign key cascade, all its sets.\n 81    Future<void> deletePlan(int id) async {\n 82      final db = await database;\n 83      await db.delete('workout_plans', where: 'id = ?', whereArgs: [id]);\n 84    }",
      "what": "A parameterized query. The ? is filled in from whereArgs, so the id is never pasted into the SQL text."
    },
    {
      "file": "lib/db/database_helper.dart",
      "lines": "95–106",
      "code": " 95    /// Counts finished workouts, not sets.\n 96    ///\n 97    /// Every set in one workout shares a sessionKey, so distinct keys are\n 98    /// sessions.\n 99    Future<int> finishedWorkoutCount() async {\n100      final db = await database;\n101      final rows = await db.rawQuery(\n102        'SELECT COUNT(DISTINCT sessionKey) FROM training_logs '\n103        'WHERE sessionFinished = 1',\n104      );\n105      return Sqflite.firstIntValue(rows) ?? 0;\n106    }",
      "what": "How workouts are counted: distinct session keys among finished sets. Three sets in one workout share one key, so they count as 1."
    },
    {
      "file": "lib/db/database_helper.dart",
      "lines": "36–45",
      "code": " 36        version: 2,\n 37        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),\n 38        // version 1 had no weight column; adding it keeps every logged set\n 39        onUpgrade: (db, oldVersion, newVersion) async {\n 40          if (oldVersion < 2) {\n 41            await db.execute(\n 42              'ALTER TABLE training_logs ADD COLUMN $_weightColumn',\n 43            );\n 44          }\n 45        },",
      "what": "version: 2 and onUpgrade: a phone still on version 1 runs ALTER TABLE once to add the weight column. Old sets keep all their data and get an empty weight."
    }
  ],
  "11": [
    {
      "file": "lib/helper/gear_match.dart",
      "lines": "52–64",
      "code": " 52  GearSuggestion _score(WorkoutPlan plan, {String? preference, int? lastId}) {\n 53    var score = 0;\n 54    final reasons = <String>[];\n 55    if (preference != null && plan.equipmentTag == preference) {\n 56      score += 2;\n 57      reasons.add('+2 matches your equipment');\n 58    }\n 59    if (lastId != null && plan.id != lastId) {\n 60      score += 1;\n 61      reasons.add('+1 different from last time');\n 62    }\n 63    return GearSuggestion(plan: plan, score: score, reason: reasons.join(', '));\n 64  }",
      "what": "_score: +2 if the plan uses your preferred equipment, +1 if it is not the plan you did last time. The reasons become the text on the card."
    }
  ]
};

const storageKey = 'movement-quest-presenter';
const byId = id => document.getElementById(id);
const viewport = byId('viewport');
let saved = {};
try { saved = JSON.parse(localStorage.getItem(storageKey) || '{}') || {}; } catch { /* local reading still works without storage */ }
if (typeof saved !== 'object') saved = {};
let current = Number.isInteger(saved.current) ? Math.min(Math.max(saved.current, 0), sections.length - 1) : 0;
let running = false;
let elapsed = 0;
let previousFrame;
let scrollPosition = 0;
const edits = saved.edits && typeof saved.edits === 'object' ? saved.edits : {};
byId('speed').value = Number.isFinite(Number(saved.speed)) ? Math.min(50, Math.max(6, Number(saved.speed))) : 18;
byId('fontSize').value = Number.isFinite(Number(saved.fontSize)) ? Math.min(56, Math.max(22, Number(saved.fontSize))) : 32;

function persist() {
  try { localStorage.setItem(storageKey, JSON.stringify({ current, edits, speed: Number(byId('speed').value), fontSize: Number(byId('fontSize').value) })); }
  catch { byId('state').textContent = 'Storage unavailable: download your edits'; }
}

function pause() {
  running = false;
  byId('play').textContent = 'Start scrolling';
  byId('play').setAttribute('aria-pressed', 'false');
  byId('state').textContent = 'Paused';
}

function toggle() {
  if (running) { pause(); return; }
  if (viewport.scrollTop >= viewport.scrollHeight - viewport.clientHeight - 1) viewport.scrollTop = 0;
  scrollPosition = viewport.scrollTop;
  running = true;
  byId('play').textContent = 'Pause scrolling';
  byId('play').setAttribute('aria-pressed', 'true');
  byId('state').textContent = 'Reading';
}

function showSection(index) {
  pause();
  current = Math.max(0, Math.min(sections.length - 1, index));
  const section = sections[current];
  byId('title').textContent = section.title;
  byId('sectionMeta').textContent = `Section ${current + 1} / ${sections.length} · ${section.time}`;
  byId('cue').textContent = section.cue;
  renderCode();
  byId('script').replaceChildren();
  const text = typeof edits[current] === 'string' ? edits[current] : section.text;
  for (const paragraph of text.split(/\n\s*\n/)) {
    const node = document.createElement('p');
    node.textContent = paragraph;
    byId('script').append(node);
  }
  for (const [number, button] of [...byId('sections').children].entries()) button.setAttribute('aria-current', String(number === current));
  byId('sectionSelect').value = current;
  byId('position').textContent = `${current + 1} of ${sections.length} · ${section.title}`;
  byId('previous').disabled = current === 0;
  byId('next').disabled = current === sections.length - 1;
  viewport.scrollTop = 0;
  scrollPosition = 0;
  updateProgress();
  persist();
}

function renderCode() {
  const panel = byId('code');
  panel.replaceChildren();
  for (const block of codeBlocks[current] || []) {
    const file = document.createElement('div');
    file.className = 'code-file';
    file.textContent = `${block.file} · lines ${block.lines}`;
    const code = document.createElement('pre');
    code.textContent = block.code;
    const what = document.createElement('p');
    what.className = 'code-what';
    const label = document.createElement('strong');
    label.textContent = 'What it does: ';
    what.append(label, block.what);
    panel.append(file, code, what);
  }
}

function updateProgress() {
  const maximum = viewport.scrollHeight - viewport.clientHeight;
  byId('progress').value = maximum > 0 ? 100 * viewport.scrollTop / maximum : 100;
}

function frame(now) {
  const delta = previousFrame === undefined ? 0 : Math.min((now - previousFrame) / 1000, 0.1);
  previousFrame = now;
  if (running) {
    elapsed += delta;
    scrollPosition += delta * Number(byId('speed').value);
    viewport.scrollTop = scrollPosition;
    if (viewport.scrollTop >= viewport.scrollHeight - viewport.clientHeight - 1) pause();
  }
  const seconds = Math.floor(elapsed);
  byId('timer').textContent = `${String(Math.floor(seconds / 60)).padStart(2, '0')}:${String(seconds % 60).padStart(2, '0')}`;
  requestAnimationFrame(frame);
}

sections.forEach((section, index) => {
  const button = document.createElement('button');
  const number = document.createElement('span');
  number.textContent = `${String(index + 1).padStart(2, '0')} `;
  button.append(number, section.title);
  button.addEventListener('click', () => showSection(index));
  byId('sections').append(button);
  const option = document.createElement('option');
  option.value = index;
  option.textContent = `${index + 1}. ${section.title}`;
  byId('sectionSelect').append(option);
});

function updateSettings() {
  byId('speedValue').textContent = byId('speed').value;
  byId('fontValue').textContent = byId('fontSize').value;
  document.documentElement.style.setProperty('--script-size', `${byId('fontSize').value}px`);
  updateProgress();
  persist();
}

byId('play').addEventListener('click', toggle);
byId('previous').addEventListener('click', () => showSection(current - 1));
byId('next').addEventListener('click', () => showSection(current + 1));
byId('sectionSelect').addEventListener('change', event => showSection(Number(event.target.value)));
byId('speed').addEventListener('input', updateSettings);
byId('fontSize').addEventListener('input', updateSettings);
byId('resetTimer').addEventListener('click', () => { elapsed = 0; });
byId('focus').addEventListener('click', () => {
  const compact = document.body.classList.toggle('compact');
  byId('focus').setAttribute('aria-pressed', String(compact));
  byId('focus').textContent = compact ? 'Show sections' : 'Focus view';
  updateProgress();
});
byId('edit').addEventListener('click', () => {
  pause();
  byId('editorText').value = typeof edits[current] === 'string' ? edits[current] : sections[current].text;
  byId('editor').showModal();
});
byId('cancelEdit').addEventListener('click', () => byId('editor').close());
byId('saveEdit').addEventListener('click', () => {
  edits[current] = byId('editorText').value;
  byId('editor').close();
  showSection(current);
});
byId('download').addEventListener('click', () => {
  const text = sections.map((section, index) => `${index + 1}. ${section.title}\n\nACTION CUE: ${section.cue}\n\n${(codeBlocks[index] || []).map(block => `${block.file} · lines ${block.lines}\n${block.code}\nWhat it does: ${block.what}\n\n`).join('')}${typeof edits[index] === 'string' ? edits[index] : section.text}`).join('\n\n----------------\n\n');
  const url = URL.createObjectURL(new Blob([text], { type: 'text/plain;charset=utf-8' }));
  const anchor = document.createElement('a');
  anchor.href = url;
  anchor.download = 'movement-quest-presentation.txt';
  anchor.click();
  setTimeout(() => URL.revokeObjectURL(url), 1000);
});
viewport.addEventListener('scroll', () => { scrollPosition = viewport.scrollTop; updateProgress(); });
document.addEventListener('visibilitychange', () => { if (document.hidden) pause(); previousFrame = undefined; });
document.addEventListener('keydown', event => {
  if (event.code === 'Escape') { pause(); return; }
  if (byId('editor').open || !(event.target instanceof Element) || event.target.closest('input,textarea,select,button,[contenteditable="true"]')) return;
  if (event.code === 'Space') { event.preventDefault(); toggle(); }
  if (event.code === 'ArrowRight') { event.preventDefault(); showSection(current + 1); }
  if (event.code === 'ArrowLeft') { event.preventDefault(); showSection(current - 1); }
  if (event.code === 'Home') { event.preventDefault(); showSection(current); }
});
window.addEventListener('resize', updateProgress);
updateSettings();
showSection(current);
requestAnimationFrame(frame);
