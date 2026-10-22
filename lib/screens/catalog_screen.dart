import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/workout_plan.dart';
import '../widgets/empty_state.dart';
import '../widgets/workout_card.dart';
import 'plan_form_screen.dart';
import 'workout_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  List<WorkoutPlan>? _plans;
  int _finished = 0;
  String? _tag;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final helper = DatabaseHelper.instance;
    final plans = await helper.plans();
    final finished = await helper.finishedWorkoutCount();
    if (!mounted) return;
    setState(() {
      _plans = plans;
      _finished = finished;
    });
  }

  Future<void> _open(Widget screen) async {
    await Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => screen));
    if (!mounted) return;
    await _load();
  }

  List<WorkoutPlan> _matching(List<WorkoutPlan> plans) {
    if (_tag == null) return plans;
    return [
      for (final plan in plans)
        if (plan.equipmentTag == _tag) plan,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final plans = _plans;
    return Scaffold(
      appBar: AppBar(title: const Text('Plans')),
      body: switch (plans) {
        null => const Center(child: CircularProgressIndicator()),
        [] => const EmptyState(
          message: 'Add a plan first.',
          icon: Icons.fitness_center,
        ),
        _ => _PlanList(
          plans: _matching(plans),
          finished: _finished,
          tag: _tag,
          onTagSelected: (tag) => setState(() => _tag = tag),
          onOpen: (plan) => _open(WorkoutScreen(plan: plan)),
        ),
      },
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _open(const PlanFormScreen()),
        icon: const Icon(Icons.add),
        label: const Text('New Plan'),
      ),
    );
  }
}

class _PlanList extends StatelessWidget {
  const _PlanList({
    required this.plans,
    required this.finished,
    required this.tag,
    required this.onTagSelected,
    required this.onOpen,
  });

  final List<WorkoutPlan> plans;
  final int finished;
  final String? tag;
  final ValueChanged<String?> onTagSelected;
  final ValueChanged<WorkoutPlan> onOpen;

  @override
  Widget build(BuildContext context) {
    return ListView(
      // bottom padding keeps the last card clear of the FAB
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
      children: [
        Text(
          'Workouts finished: $finished',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            ChoiceChip(
              label: const Text('All'),
              selected: tag == null,
              onSelected: (_) => onTagSelected(null),
            ),
            for (final equipment in equipmentTags)
              ChoiceChip(
                label: Text(equipment),
                selected: tag == equipment,
                onSelected: (_) => onTagSelected(equipment),
              ),
          ],
        ),
        const SizedBox(height: 8),
        for (final plan in plans)
          WorkoutCard(
            key: ValueKey(plan.id),
            plan: plan,
            onTap: () => onOpen(plan),
          ),
        if (plans.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text('No plans use $tag yet.', textAlign: TextAlign.center),
          ),
      ],
    );
  }
}
