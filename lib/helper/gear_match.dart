import '../models/workout_plan.dart';

class GearSuggestion {
  const GearSuggestion({
    required this.plan,
    required this.score,
    required this.reason,
  });

  final WorkoutPlan plan;
  final int score;

  /// The points awarded, such as "+2 matches your equipment".
  ///
  /// Empty when the plan won on id alone.
  final String reason;
}

/// Picks one plan to suggest from fixed scoring rules.
///
/// +2 when the plan's equipment matches [preference], +1 when it isn't the
/// plan from the last finished workout. A null preference or a null
/// [lastFinishedWorkoutId] skips that rule. Ties go to the lower id. Returns
/// null when there are no plans.
GearSuggestion? suggestPlan({
  String? preference,
  required List<WorkoutPlan> plans,
  int? lastFinishedWorkoutId,
}) {
  if (plans.isEmpty) return null;
  final ranked = [
    for (final plan in plans)
      _score(plan, preference: preference, lastId: lastFinishedWorkoutId),
  ]..sort(_byScoreThenId);
  return ranked.first;
}

/// The comparison point for [suggestPlan]: equipment match only.
///
/// Ties, including no match at all, go to the lower id.
WorkoutPlan? baselineSuggestion({
  String? preference,
  required List<WorkoutPlan> plans,
}) {
  if (plans.isEmpty) return null;
  final ranked = [
    for (final plan in plans) _score(plan, preference: preference),
  ]..sort(_byScoreThenId);
  return ranked.first.plan;
}

GearSuggestion _score(WorkoutPlan plan, {String? preference, int? lastId}) {
  var score = 0;
  final reasons = <String>[];
  if (preference != null && plan.equipmentTag == preference) {
    score += 2;
    reasons.add('+2 matches your equipment');
  }
  if (lastId != null && plan.id != lastId) {
    score += 1;
    reasons.add('+1 different from last time');
  }
  return GearSuggestion(plan: plan, score: score, reason: reasons.join(', '));
}

int _byScoreThenId(GearSuggestion a, GearSuggestion b) {
  final byScore = b.score.compareTo(a.score);
  if (byScore != 0) return byScore;
  // plans come from the database, so the ids are always set
  return (a.plan.id ?? 0).compareTo(b.plan.id ?? 0);
}
