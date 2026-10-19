import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'db/database_helper.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await DatabaseHelper.instance.database;
  final planCount = Sqflite.firstIntValue(
    await db.rawQuery('SELECT COUNT(*) FROM workout_plans'),
  );
  debugPrint('workout plans: $planCount');
  runApp(const MovementQuestApp());
}

class MovementQuestApp extends StatelessWidget {
  const MovementQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movement Quest',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const HomeScreen(),
    );
  }
}
