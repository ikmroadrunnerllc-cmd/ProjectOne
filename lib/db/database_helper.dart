import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/workout_plan.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  // a cached future, so two early callers can't open the file twice
  Future<Database>? _db;

  Future<Database> get database => _db ??= _open();

  Future<Database> _open() async {
    return openAt(join(await getDatabasesPath(), 'movement_quest.db'));
  }

  /// Opens the database at [path] and makes it the shared instance.
  ///
  /// Tests pass a temp file here instead of the app's default location.
  Future<Database> openAt(String path) {
    return _db = openDatabase(
      path,
      version: 1,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _onCreate,
    );
  }

  Future<List<WorkoutPlan>> plans() async {
    final db = await database;
    final rows = await db.query('workout_plans', orderBy: 'id');
    return rows.map(WorkoutPlan.fromMap).toList();
  }

  Future<int> insertPlan(WorkoutPlan plan) async {
    final db = await database;
    return db.insert('workout_plans', plan.toMap());
  }

  Future<void> updatePlan(WorkoutPlan plan) async {
    final db = await database;
    await db.update(
      'workout_plans',
      plan.toMap(),
      where: 'id = ?',
      whereArgs: [plan.id],
    );
  }

  /// Deletes a plan and, through the foreign key cascade, all its sets.
  Future<void> deletePlan(int id) async {
    final db = await database;
    await db.delete('workout_plans', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> setCountForPlan(int id) async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT COUNT(*) FROM training_logs WHERE workoutId = ?',
      [id],
    );
    return Sqflite.firstIntValue(rows) ?? 0;
  }

  /// Counts finished workouts, not sets.
  ///
  /// Every set in one workout shares a sessionKey, so distinct keys are
  /// sessions.
  Future<int> finishedWorkoutCount() async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT COUNT(DISTINCT sessionKey) FROM training_logs '
      'WHERE sessionFinished = 1',
    );
    return Sqflite.firstIntValue(rows) ?? 0;
  }

  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();
    batch.execute('''
      CREATE TABLE workout_plans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        equipmentTag TEXT NOT NULL,
        planNote TEXT,
        effortPreference INTEGER NOT NULL
          CHECK (effortPreference BETWEEN 1 AND 5)
      )
    ''');
    batch.execute('''
      CREATE TABLE training_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workoutId INTEGER NOT NULL
          REFERENCES workout_plans(id) ON DELETE CASCADE,
        sessionKey TEXT NOT NULL,
        exerciseLabel TEXT NOT NULL,
        repetitions INTEGER NOT NULL CHECK (repetitions > 0),
        loggedAt TEXT NOT NULL,
        sessionFinished INTEGER NOT NULL DEFAULT 0
          CHECK (sessionFinished IN (0, 1))
      )
    ''');
    batch.execute(
      'CREATE INDEX idx_training_logs_session ON training_logs(sessionKey)',
    );
    batch.execute(
      'CREATE INDEX idx_training_logs_workout ON training_logs(workoutId)',
    );

    const seed = [
      WorkoutPlan(
        title: 'Morning Bodyweight',
        equipmentTag: 'None',
        planNote: 'Push-ups, squats, lunges',
        effortPreference: 2,
      ),
      WorkoutPlan(
        title: 'Dumbbell Basics',
        equipmentTag: 'Dumbbells',
        effortPreference: 3,
      ),
      WorkoutPlan(
        title: 'Mat Core',
        equipmentTag: 'Mat',
        planNote: 'Plank holds between sets',
        effortPreference: 2,
      ),
    ];
    for (final plan in seed) {
      batch.insert('workout_plans', plan.toMap());
    }
    await batch.commit(noResult: true);
  }
}
