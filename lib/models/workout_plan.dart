const equipmentTags = ['None', 'Dumbbells', 'Resistance Band', 'Mat'];

class WorkoutPlan {
  const WorkoutPlan({
    this.id,
    required this.title,
    required this.equipmentTag,
    this.planNote,
    required this.effortPreference,
  });

  factory WorkoutPlan.fromMap(Map<String, Object?> map) {
    return WorkoutPlan(
      id: map['id'] as int?,
      title: map['title'] as String,
      equipmentTag: map['equipmentTag'] as String,
      planNote: map['planNote'] as String?,
      effortPreference: map['effortPreference'] as int,
    );
  }

  final int? id;
  final String title;
  final String equipmentTag;
  final String? planNote;
  final int effortPreference;

  Map<String, Object?> toMap({bool includeId = false}) {
    return {
      if (includeId) 'id': id,
      'title': title,
      'equipmentTag': equipmentTag,
      'planNote': planNote,
      'effortPreference': effortPreference,
    };
  }

  WorkoutPlan copyWith({
    int? id,
    String? title,
    String? equipmentTag,
    String? planNote,
    int? effortPreference,
  }) {
    return WorkoutPlan(
      id: id ?? this.id,
      title: title ?? this.title,
      equipmentTag: equipmentTag ?? this.equipmentTag,
      planNote: planNote ?? this.planNote,
      effortPreference: effortPreference ?? this.effortPreference,
    );
  }
}
