import 'package:shared_preferences/shared_preferences.dart';

import '../demo/demo_setup.dart';
import 'workout_plan.dart';

class AppSettings {
  const AppSettings({
    this.defaultEffort = 3,
    this.preferredEquipment,
    this.darkMode = false,
    this.showGearMatch = true,
  });

  final int defaultEffort;

  /// The equipment tag Gear Match favors.
  ///
  /// Null means no preference.
  final String? preferredEquipment;
  final bool darkMode;
  final bool showGearMatch;

  /// Reads saved settings, falling back to defaults for anything missing.
  ///
  /// Stored values outside the allowed range or list are ignored rather than
  /// trusted.
  static Future<AppSettings> load({bool demo = demoMode}) async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = demo ? 'demo.' : '';
    final effort = prefs.getInt('${prefix}defaultEffort');
    final equipment = prefs.getString('${prefix}preferredEquipment');
    return AppSettings(
      defaultEffort: effort != null && effort >= 1 && effort <= 5 ? effort : 3,
      preferredEquipment: equipmentTags.contains(equipment) ? equipment : null,
      darkMode: prefs.getBool('${prefix}darkMode') ?? false,
      showGearMatch: prefs.getBool('${prefix}showGearMatch') ?? true,
    );
  }

  Future<void> save({bool demo = demoMode}) async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = demo ? 'demo.' : '';
    final equipment = preferredEquipment;
    await Future.wait([
      prefs.setInt('${prefix}defaultEffort', defaultEffort),
      if (equipment == null)
        prefs.remove('${prefix}preferredEquipment')
      else
        prefs.setString('${prefix}preferredEquipment', equipment),
      prefs.setBool('${prefix}darkMode', darkMode),
      prefs.setBool('${prefix}showGearMatch', showGearMatch),
    ]);
  }

  // preferredEquipment is nullable, so clearing it needs its own flag
  AppSettings copyWith({
    int? defaultEffort,
    String? preferredEquipment,
    bool clearEquipment = false,
    bool? darkMode,
    bool? showGearMatch,
  }) {
    return AppSettings(
      defaultEffort: defaultEffort ?? this.defaultEffort,
      preferredEquipment: clearEquipment
          ? null
          : preferredEquipment ?? this.preferredEquipment,
      darkMode: darkMode ?? this.darkMode,
      showGearMatch: showGearMatch ?? this.showGearMatch,
    );
  }
}
