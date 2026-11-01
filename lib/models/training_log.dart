const exerciseLabels = [
  'Push-ups',
  'Squats',
  'Bench Press',
  'Lunges',
  'Curls',
  'Plank',
  'Jumping Jacks',
];

class TrainingLog {
  const TrainingLog({
    this.id,
    required this.workoutId,
    required this.sessionKey,
    required this.exerciseLabel,
    required this.repetitions,
    this.weight,
    required this.loggedAt,
    this.sessionFinished = false,
  });

  factory TrainingLog.fromMap(Map<String, Object?> map) {
    return TrainingLog(
      id: map['id'] as int?,
      workoutId: map['workoutId'] as int,
      sessionKey: map['sessionKey'] as String,
      exerciseLabel: map['exerciseLabel'] as String,
      repetitions: map['repetitions'] as int,
      weight: (map['weight'] as num?)?.toDouble(),
      loggedAt: DateTime.parse(map['loggedAt'] as String),
      sessionFinished: map['sessionFinished'] == 1,
    );
  }

  final int? id;
  final int workoutId;
  final String sessionKey;
  final String exerciseLabel;
  final int repetitions;

  /// Load in pounds, whatever the equipment: bar, dumbbell or band.
  ///
  /// Null for bodyweight sets.
  final double? weight;

  final DateTime loggedAt;
  final bool sessionFinished;

  Map<String, Object?> toMap({bool includeId = false}) {
    return {
      if (includeId) 'id': id,
      'workoutId': workoutId,
      'sessionKey': sessionKey,
      'exerciseLabel': exerciseLabel,
      'repetitions': repetitions,
      'weight': weight,
      'loggedAt': loggedAt.toIso8601String(),
      'sessionFinished': sessionFinished ? 1 : 0,
    };
  }

  TrainingLog copyWith({
    int? id,
    int? workoutId,
    String? sessionKey,
    String? exerciseLabel,
    int? repetitions,
    double? weight,
    bool clearWeight = false,
    DateTime? loggedAt,
    bool? sessionFinished,
  }) {
    return TrainingLog(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      sessionKey: sessionKey ?? this.sessionKey,
      exerciseLabel: exerciseLabel ?? this.exerciseLabel,
      repetitions: repetitions ?? this.repetitions,
      weight: clearWeight ? null : weight ?? this.weight,
      loggedAt: loggedAt ?? this.loggedAt,
      sessionFinished: sessionFinished ?? this.sessionFinished,
    );
  }
}
