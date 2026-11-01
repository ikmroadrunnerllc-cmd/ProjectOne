import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

const demoMode = bool.fromEnvironment('DEMO_MODE');
const demoDatabaseName = 'movement_quest_demo.db';

/// Resets only rehearsal storage when a new reset token is supplied.
Future<String> prepareDemoDatabase({
  required String directory,
  required String resetToken,
}) async {
  final path = join(directory, demoDatabaseName);
  if (resetToken.isEmpty) return path;
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getString('demo.resetToken') == resetToken) return path;
  await deleteDatabase(path);
  for (final key in prefs.getKeys().where((key) => key.startsWith('demo.'))) {
    await prefs.remove(key);
  }
  await prefs.setString('demo.resetToken', resetToken);
  return path;
}

/// Adds fictional history after the usual plans have been created.
Future<void> seedDemoData(Database db) async {
  await db.insert('workout_plans', {
    'title': 'Cascade Demo',
    'equipmentTag': 'Resistance Band',
    'planNote': 'Disposable plan for the cascade deletion demonstration',
    'effortPreference': 3,
  });
  final plans = await db.query('workout_plans', orderBy: 'id', limit: 1);
  final started = DateTime(2026, 10, 30, 8);
  final batch = db.batch();
  for (final entry in [('Push-ups', 8), ('Squats', 10)]) {
    batch.insert('training_logs', {
      'workoutId': plans.first['id'],
      'sessionKey': '${started.millisecondsSinceEpoch}',
      'exerciseLabel': entry.$1,
      'repetitions': entry.$2,
      'loggedAt': started.toIso8601String(),
      'sessionFinished': 1,
    });
  }
  await batch.commit(noResult: true);
}
