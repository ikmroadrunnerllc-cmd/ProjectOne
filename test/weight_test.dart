import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:movement_quest/db/database_helper.dart';
import 'package:movement_quest/models/training_log.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  final helper = DatabaseHelper.instance;
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('movement-quest-weight-');
  });

  tearDown(() async {
    await helper.close();
    await directory.delete(recursive: true);
  });

  group('weight column', () {
    test('saves, edits and clears the weight on a set', () async {
      await helper.openAt(join(directory.path, 'weight.db'));
      final plan = (await helper.plans()).first;
      await helper.insertLog(
        TrainingLog(
          workoutId: plan.id!,
          sessionKey: '1000',
          exerciseLabel: 'Bench Press',
          repetitions: 5,
          weight: 135,
          loggedAt: DateTime(2026, 10, 31),
          sessionFinished: true,
        ),
      );
      final saved = (await helper.finishedSets()).single.log;
      expect(saved.weight, 135);

      await helper.updateLog(saved.copyWith(weight: 137.5));
      expect((await helper.finishedSets()).single.log.weight, 137.5);

      await helper.updateLog(saved.copyWith(clearWeight: true));
      expect((await helper.finishedSets()).single.log.weight, isNull);
    });

    test('upgrading a version 1 database keeps its sets', () async {
      final path = join(directory.path, 'old.db');
      final old = await databaseFactoryFfi.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, _) async {
            await db.execute(
              'CREATE TABLE workout_plans (id INTEGER PRIMARY KEY, '
              'title TEXT, equipmentTag TEXT, planNote TEXT, '
              'effortPreference INTEGER)',
            );
            await db.execute(
              'CREATE TABLE training_logs (id INTEGER PRIMARY KEY, '
              'workoutId INTEGER, sessionKey TEXT, exerciseLabel TEXT, '
              'repetitions INTEGER, loggedAt TEXT, sessionFinished INTEGER)',
            );
            await db.insert('workout_plans', {
              'title': 'Old Plan',
              'equipmentTag': 'None',
              'effortPreference': 2,
            });
            await db.insert('training_logs', {
              'workoutId': 1,
              'sessionKey': '1000',
              'exerciseLabel': 'Squats',
              'repetitions': 10,
              'loggedAt': DateTime(2026, 10, 1).toIso8601String(),
              'sessionFinished': 1,
            });
          },
        ),
      );
      await old.close();

      await helper.openAt(path);
      final kept = (await helper.finishedSets()).single.log;
      expect(kept.repetitions, 10);
      expect(kept.weight, isNull);
    });
  });
}
