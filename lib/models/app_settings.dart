import 'package:shared_preferences/shared_preferences.dart';

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
  static Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final effort = prefs.getInt('defaultEffort');
    final equipment = prefs.getString('preferredEquipment');
    return AppSettings(
      defaultEffort: effort != null && effort >= 1 && effort <= 5 ? effort : 3,
      preferredEquipment: equipmentTags.contains(equipment) ? equipment : null,
      darkMode: prefs.getBool('darkMode') ?? false,
      showGearMatch: prefs.getBool('showGearMatch') ?? true,
    );
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final equipment = preferredEquipment;
    await Future.wait([
      prefs.setInt('defaultEffort', defaultEffort),
      if (equipment == null)
        prefs.remove('preferredEquipment')
      else
        prefs.setString('preferredEquipment', equipment),
      prefs.setBool('darkMode', darkMode),
      prefs.setBool('showGearMatch', showGearMatch),
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
