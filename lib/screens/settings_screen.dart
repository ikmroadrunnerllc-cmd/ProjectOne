import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../models/workout_plan.dart';
import '../widgets/effort_slider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.settings,
    required this.onChanged,
  });

  final AppSettings settings;
  final ValueChanged<AppSettings> onChanged;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // the slider moves locally while dragging and saves once on release
  late int _effort = widget.settings.defaultEffort;
  bool _saving = false;

  Future<void> _save(AppSettings next) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await next.save();
    } catch (e) {
      debugPrint('save settings failed: $e');
      if (!mounted) return;
      setState(() {
        _saving = false;
        _effort = widget.settings.defaultEffort;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save. Try again.')),
      );
      return;
    }
    // the app root outlives this tab, so pass the change up even if the user
    // has already switched away
    widget.onChanged(next);
    if (!mounted) return;
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.settings;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: EffortSlider(
              label: 'Default effort',
              effort: _effort,
              onChanged: _saving
                  ? null
                  : (effort) => setState(() => _effort = effort),
              onChangeEnd: (effort) =>
                  _save(settings.copyWith(defaultEffort: effort)),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String?>(
              initialValue: settings.preferredEquipment,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Preferred equipment',
              ),
              items: [
                const DropdownMenuItem(child: Text('No preference')),
                for (final tag in equipmentTags)
                  DropdownMenuItem(value: tag, child: Text(tag)),
              ],
              onChanged: _saving
                  ? null
                  : (tag) => _save(
                      settings.copyWith(
                        preferredEquipment: tag,
                        clearEquipment: tag == null,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Dark mode'),
            value: settings.darkMode,
            onChanged: _saving
                ? null
                : (on) => _save(settings.copyWith(darkMode: on)),
          ),
          SwitchListTile(
            title: const Text('Show Gear Match'),
            subtitle: const Text('Suggestion card on the Plans tab'),
            value: settings.showGearMatch,
            onChanged: _saving
                ? null
                : (on) => _save(settings.copyWith(showGearMatch: on)),
          ),
        ],
      ),
    );
  }
}
