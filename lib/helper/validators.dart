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
