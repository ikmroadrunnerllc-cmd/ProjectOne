import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'db/database_helper.dart';
import 'demo/demo_setup.dart';
import 'models/app_settings.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (demoMode) {
    await prepareDemoDatabase(
      directory: await getDatabasesPath(),
      resetToken: const String.fromEnvironment('DEMO_RESET'),
    );
  }
  final db = await DatabaseHelper.instance.database;
  final planCount = Sqflite.firstIntValue(
    await db.rawQuery('SELECT COUNT(*) FROM workout_plans'),
  );
  debugPrint('workout plans: $planCount');

  var settings = const AppSettings();
  try {
    settings = await AppSettings.load();
  } catch (e) {
    // unreadable preferences shouldn't stop the logbook from opening
    debugPrint('load settings failed: $e');
  }
  runApp(MovementQuestApp(settings: settings));
}

class MovementQuestApp extends StatefulWidget {
  const MovementQuestApp({super.key, required this.settings});

  final AppSettings settings;

  @override
  State<MovementQuestApp> createState() => _MovementQuestAppState();
}

class _MovementQuestAppState extends State<MovementQuestApp> {
  late AppSettings _settings = widget.settings;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movement Quest',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      darkTheme: ThemeData(
        colorScheme: .fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _settings.darkMode ? ThemeMode.dark : ThemeMode.light,
      home: HomeScreen(
        settings: _settings,
        onSettingsChanged: (settings) => setState(() => _settings = settings),
      ),
    );
  }
}
