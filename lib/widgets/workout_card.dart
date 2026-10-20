import 'package:flutter/material.dart';

import '../models/workout_plan.dart';

class WorkoutCard extends StatelessWidget {
  const WorkoutCard({super.key, required this.plan, required this.onTap});

  final WorkoutPlan plan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final note = plan.planNote;
    return Semantics(
      button: true,
      label:
          '${plan.title}, ${plan.equipmentTag}, '
          'effort ${plan.effortPreference} of 5',
      onTap: onTap,
      excludeSemantics: true,
      child: Card(
        child: ListTile(
          title: Text(plan.title),
          subtitle: Text(
            [
              '${plan.equipmentTag} · Effort ${plan.effortPreference}/5',
              if (note != null && note.isNotEmpty) note,
            ].join('\n'),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      ),
    );
  }
}
