import 'package:flutter/material.dart';

import '../models/workout_plan.dart';

class PlanFormScreen extends StatelessWidget {
  const PlanFormScreen({super.key, this.plan});

  final WorkoutPlan? plan;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(plan == null ? 'New Plan' : 'Edit Plan')),
      body: const Center(child: Text('The plan form will show here.')),
    );
  }
}
