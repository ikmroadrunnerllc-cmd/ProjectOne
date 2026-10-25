import 'package:flutter_test/flutter_test.dart';
import 'package:movement_quest/models/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AppSettings', () {
    test('falls back to defaults for missing or out of range values', () async {
      SharedPreferences.setMockInitialValues({
        'defaultEffort': 9,
        'preferredEquipment': 'Kettlebell',
      });
      final settings = await AppSettings.load();
      expect(settings.defaultEffort, 3);
      expect(settings.preferredEquipment, isNull);
      expect(settings.darkMode, isFalse);
      expect(settings.showGearMatch, isTrue);
    });

    test('reads back what it saved', () async {
      SharedPreferences.setMockInitialValues({});
      await const AppSettings(
        defaultEffort: 5,
        preferredEquipment: 'Mat',
        darkMode: true,
        showGearMatch: false,
      ).save();
      final settings = await AppSettings.load();
      expect(settings.defaultEffort, 5);
      expect(settings.preferredEquipment, 'Mat');
      expect(settings.darkMode, isTrue);
      expect(settings.showGearMatch, isFalse);
    });

    test('clears the preference when switched to no preference', () async {
      SharedPreferences.setMockInitialValues({});
      const picked = AppSettings(preferredEquipment: 'Mat');
      await picked.save();
      await picked.copyWith(clearEquipment: true).save();
      expect((await AppSettings.load()).preferredEquipment, isNull);
    });
  });
}
