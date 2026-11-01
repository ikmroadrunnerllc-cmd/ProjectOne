/// Checks a reps entry from a text field.
///
/// Returns null for a whole number from 1 to 999, otherwise the message to
/// show under the field. The workout screen and the history edit dialog both
/// use this, so the two can't drift apart.
String? validateReps(String? raw) {
  final text = raw?.trim() ?? '';
  if (text.isEmpty) return 'Enter reps.';
  final reps = int.tryParse(text);
  if (reps == null) return 'Use a whole number.';
  if (reps < 1 || reps > 999) return 'Reps must be 1 to 999.';
  return null;
}

/// Checks an optional weight entry, in pounds.
///
/// Blank is fine, since bodyweight sets have no load. Otherwise it must be a
/// number above 0 and at most 2000. Halves like 2.5 are allowed.
String? validateWeight(String? raw) {
  final text = raw?.trim() ?? '';
  if (text.isEmpty) return null;
  final weight = double.tryParse(text);
  if (weight == null) return 'Use a number.';
  if (weight <= 0) return 'Weight must be above 0.';
  if (weight > 2000) return 'Weight must be 2000 or less.';
  return null;
}

/// Reads a weight field that already passed [validateWeight].
///
/// Blank means a bodyweight set, so it returns null.
double? parseWeight(String raw) {
  final text = raw.trim();
  return text.isEmpty ? null : double.parse(text);
}

/// Shows 135.0 as "135" and 2.5 as "2.5".
String formatWeight(double weight) {
  return weight == weight.roundToDouble() ? '${weight.toInt()}' : '$weight';
}
