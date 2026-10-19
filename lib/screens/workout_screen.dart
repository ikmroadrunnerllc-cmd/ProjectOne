import 'package:flutter/material.dart';

import '../models/workout_plan.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key, required this.plan});

  final WorkoutPlan plan;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(plan.title)),
      body: const Center(child: Text('Workout logging will show here.')),
    );
  }
}
