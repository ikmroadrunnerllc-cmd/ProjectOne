import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/training_log.dart';
import '../models/workout_plan.dart';

typedef HistorySet = ({TrainingLog log, String planTitle});

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

  /// The plan id of the most recently started finished workout, if any.
  Future<int?> lastFinishedWorkoutId() async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT workoutId FROM training_logs WHERE sessionFinished = 1 '
      'ORDER BY CAST(sessionKey AS INTEGER) DESC LIMIT 1',
    );
    return Sqflite.firstIntValue(rows);
  }

  Future<int> insertLog(TrainingLog log) async {
    final db = await database;
    return db.insert('training_logs', log.toMap());
  }

  /// Marks every set in a session finished.
  ///
  /// Runs in a transaction so a session is never left half finished.
  Future<void> finishSession(String sessionKey) async {
    final db = await database;
    await db.transaction(
      (txn) => txn.update(
        'training_logs',
        {'sessionFinished': 1},
        where: 'sessionKey = ?',
        whereArgs: [sessionKey],
      ),
    );
  }

  /// Finished sets with their plan title, newest session first.
  ///
  /// Sets within a session stay in the order they were logged, so callers can
  /// group consecutive rows by sessionKey.
  Future<List<HistorySet>> finishedSets() async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT l.*, p.title AS planTitle FROM training_logs l '
      'JOIN workout_plans p ON p.id = l.workoutId '
      'WHERE l.sessionFinished = 1 '
      'ORDER BY CAST(l.sessionKey AS INTEGER) DESC, l.id',
    );
    return [
      for (final row in rows)
        (log: TrainingLog.fromMap(row), planTitle: row['planTitle'] as String),
    ];
  }

  Future<void> updateLog(TrainingLog log) async {
    final db = await database;
    await db.update(
      'training_logs',
      log.toMap(),
      where: 'id = ?',
      whereArgs: [log.id],
    );
  }

  Future<void> deleteLog(int id) async {
    final db = await database;
    await db.delete('training_logs', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteUnfinishedSets(String sessionKey) async {
    final db = await database;
    await db.delete(
      'training_logs',
      where: 'sessionKey = ? AND sessionFinished = 0',
      whereArgs: [sessionKey],
    );
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
