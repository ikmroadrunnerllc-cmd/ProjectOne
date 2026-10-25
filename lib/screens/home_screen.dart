import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import 'catalog_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  final AppSettings settings;
  final ValueChanged<AppSettings> onSettingsChanged;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // rebuilt on every switch so each tab reloads from the database
      body: [
        CatalogScreen(settings: widget.settings),
        const HistoryScreen(),
        SettingsScreen(
          settings: widget.settings,
          onChanged: widget.onSettingsChanged,
        ),
      ][_tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Plans'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
