import 'package:flutter_test/flutter_test.dart';
import 'package:movement_quest/helper/gear_match.dart';
import 'package:movement_quest/models/workout_plan.dart';

WorkoutPlan plan(int id, String tag) {
  return WorkoutPlan(
    id: id,
    title: 'Plan $id',
    equipmentTag: tag,
    effortPreference: 3,
  );
}

void main() {
  group('suggestPlan', () {
    test(
      'picks the plan that matches equipment and differs from last time',
      () {
        final a = plan(1, 'None');
        final b = plan(2, 'None');
        final c = plan(3, 'Dumbbells');
        final suggestion = suggestPlan(
          preference: 'None',
          plans: [c, b, a],
          lastFinishedWorkoutId: 2,
        );
        expect(suggestion?.plan, a);
        expect(suggestion?.score, 3);
        expect(
          suggestion?.reason,
          '+2 matches your equipment, +1 different from last time',
        );
        expect(baselineSuggestion(preference: 'None', plans: [c, b, a]), a);
      },
    );

    test('returns null when there are no plans', () {
      expect(suggestPlan(preference: 'None', plans: []), isNull);
      expect(baselineSuggestion(preference: 'None', plans: []), isNull);
    });

    test('skips the +1 when there is no finished workout yet', () {
      final suggestion = suggestPlan(
        preference: 'Mat',
        plans: [plan(1, 'None'), plan(2, 'Mat')],
      );
      expect(suggestion?.plan.id, 2);
      expect(suggestion?.score, 2);
      expect(suggestion?.reason, '+2 matches your equipment');
    });

    test('breaks a tie with the lower id', () {
      final suggestion = suggestPlan(
        preference: 'Dumbbells',
        plans: [plan(7, 'Dumbbells'), plan(4, 'Dumbbells')],
        lastFinishedWorkoutId: 9,
      );
      expect(suggestion?.plan.id, 4);
      expect(suggestion?.score, 3);
    });

    test('ranks a wanted Mat plan below Dumbbells when the preference says '
        'Dumbbells', () {
      final mat = plan(1, 'Mat');
      final dumbbells = plan(2, 'Dumbbells');
      final suggestion = suggestPlan(
        preference: 'Dumbbells',
        plans: [mat, dumbbells],
        lastFinishedWorkoutId: 2,
      );
      // the rules only see the saved preference, not what the user wants today
      expect(suggestion?.plan, dumbbells);
      expect(suggestion?.score, 2);
    });
  });
}
