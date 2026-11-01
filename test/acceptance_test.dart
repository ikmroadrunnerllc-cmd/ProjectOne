import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:movement_quest/db/database_helper.dart';
import 'package:movement_quest/demo/demo_setup.dart';
import 'package:movement_quest/models/app_settings.dart';
import 'package:movement_quest/models/training_log.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  final helper = DatabaseHelper.instance;
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('movement-quest-test-');
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    await helper.close();
    await directory.delete(recursive: true);
  });

  Future<int> logSet(
    int planId,
    String session,
    int reps, {
    bool finished = true,
  }) {
    return helper.insertLog(
      TrainingLog(
        workoutId: planId,
        sessionKey: session,
        exerciseLabel: 'Push-ups',
        repetitions: reps,
        loggedAt: DateTime(2026, 10, 31),
        sessionFinished: finished,
      ),
    );
  }

  group('DatabaseHelper', () {
    test('counts sessions after deleting one set and then all sets', () async {
      await helper.openAt(join(directory.path, 'acceptance.db'));
      final planId = (await helper.plans()).first.id!;
      final ids = [
        for (final reps in [12, 14, 10]) await logSet(planId, '1000', reps),
      ];
      expect(await helper.finishedWorkoutCount(), 1);
      await helper.deleteLog(ids.first);
      expect(await helper.finishedWorkoutCount(), 1);
      for (final id in ids.skip(1)) {
        await helper.deleteLog(id);
      }
      expect(await helper.finishedWorkoutCount(), 0);
    });

    test('cascade deletes logs and reset keeps completed sessions', () async {
      await helper.openAt(join(directory.path, 'cascade.db'));
      final plans = await helper.plans();
      final deleted = plans[0].id!;
      final kept = plans[1].id!;
      await logSet(deleted, '1000', 12);
      await logSet(deleted, '2000', 14, finished: false);
      await logSet(kept, '3000', 10, finished: false);
      await helper.deleteUnfinishedSets('2000');
      expect(await helper.finishedWorkoutCount(), 1);
      expect(await helper.setCountForPlan(deleted), 1);
      expect(await helper.setCountForPlan(kept), 1);
      await helper.deletePlan(deleted);
      expect(await helper.finishedWorkoutCount(), 0);
      expect(await helper.setCountForPlan(deleted), 0);
      expect(await helper.setCountForPlan(kept), 1);
    });

    test('persists finished sessions after closing and reopening', () async {
      final path = join(directory.path, 'reopen.db');
      await helper.openAt(path);
      final planId = (await helper.plans()).first.id!;
      await logSet(planId, '1000', 12, finished: false);
      await logSet(planId, '1000', 14, finished: false);
      expect(await helper.finishedWorkoutCount(), 0);
      await helper.finishSession('1000');
      await helper.close();
      await helper.openAt(path);
      expect(await helper.finishedWorkoutCount(), 1);
      expect((await helper.finishedSets()).map((s) => s.log.repetitions), [
        12,
        14,
      ]);
    });

    test('demo data seeds once and survives a relaunch', () async {
      final path = join(directory.path, demoDatabaseName);
      await helper.openAt(path, demo: true);
      expect((await helper.plans()).map((p) => p.title), [
        'Morning Bodyweight',
        'Dumbbell Basics',
        'Mat Core',
        'Cascade Demo',
      ]);
      expect(await helper.finishedWorkoutCount(), 1);
      expect(
        (await helper.finishedSets()).fold(0, (n, s) => n + s.log.repetitions),
        18,
      );
      final first = (await helper.finishedSets()).first;
      await helper.updateLog(first.log.copyWith(repetitions: 9));
      await helper.close();
      await helper.openAt(path, demo: true);
      expect((await helper.finishedSets()).first.log.repetitions, 9);
      expect((await helper.plans()).length, 4);
    });

    test(
      'demo reset affects neither normal records nor normal preferences',
      () async {
        final normalPath = join(directory.path, 'movement_quest.db');
        await helper.openAt(normalPath);
        await logSet((await helper.plans()).first.id!, '1000', 25);
        await helper.close();
        await const AppSettings(darkMode: true).save(demo: false);
        await const AppSettings(defaultEffort: 5).save(demo: true);

        final demoPath = await prepareDemoDatabase(
          directory: directory.path,
          resetToken: 'take-1',
        );
        await helper.openAt(demoPath, demo: true);
        final seeded = (await helper.finishedSets()).first;
        await helper.updateLog(seeded.log.copyWith(repetitions: 99));
        await helper.close();
        await const AppSettings(defaultEffort: 4).save(demo: true);

        await prepareDemoDatabase(
          directory: directory.path,
          resetToken: 'take-1',
        );
        await helper.openAt(demoPath, demo: true);
        expect((await helper.finishedSets()).first.log.repetitions, 99);
        expect((await AppSettings.load(demo: true)).defaultEffort, 4);
        await helper.close();

        await prepareDemoDatabase(
          directory: directory.path,
          resetToken: 'take-2',
        );
        await helper.openAt(demoPath, demo: true);
        expect(
          (await helper.finishedSets()).fold(
            0,
            (n, s) => n + s.log.repetitions,
          ),
          18,
        );
        expect((await AppSettings.load(demo: true)).defaultEffort, 3);
        expect((await AppSettings.load(demo: false)).darkMode, isTrue);
        await helper.close();
        await helper.openAt(normalPath);
        expect((await helper.finishedSets()).single.log.repetitions, 25);
      },
    );
  });
}
