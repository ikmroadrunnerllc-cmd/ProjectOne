import 'package:flutter/material.dart';

import '../models/workout_plan.dart';
import 'plan_form_screen.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key, required this.plan});

  final WorkoutPlan plan;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(plan.title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Workout logging will show here.'),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => PlanFormScreen(plan: plan),
                ),
              ),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit Plan'),
            ),
          ],
        ),
      ),
    );
  }
}
