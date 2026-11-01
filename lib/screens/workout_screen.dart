import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../helper/validators.dart';
import '../models/training_log.dart';
import '../models/workout_plan.dart';
import '../widgets/set_row.dart';
import '../widgets/weight_field.dart';
import 'plan_form_screen.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key, required this.plan});

  final WorkoutPlan plan;

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reps = TextEditingController();
  final _weight = TextEditingController();
  final List<TrainingLog> _sets = [];
  late WorkoutPlan _plan = widget.plan;
  String? _sessionKey;
  String _exercise = exerciseLabels.first;
  bool _busy = false;

  int get _totalReps => _sets.fold(0, (sum, set) => sum + set.repetitions);

  @override
  void dispose() {
    _reps.dispose();
    _weight.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _start() {
    setState(() {
      _sessionKey = DateTime.now().millisecondsSinceEpoch.toString();
      _sets.clear();
    });
  }

  void _endSession() {
    _sessionKey = null;
    _sets.clear();
    _busy = false;
  }

  Future<void> _logSet(String sessionKey) async {
    if (_busy || !_formKey.currentState!.validate()) return;
    setState(() => _busy = true);

    final draft = TrainingLog(
      // plans reach this screen from the database, so the id is always set
      workoutId: _plan.id!,
      sessionKey: sessionKey,
      exerciseLabel: _exercise,
      repetitions: int.parse(_reps.text.trim()),
      weight: parseWeight(_weight.text),
      loggedAt: DateTime.now(),
    );
    try {
      final id = await DatabaseHelper.instance.insertLog(draft);
      if (!mounted) return;
      setState(() {
        _sets.add(draft.copyWith(id: id));
        _busy = false;
      });
    } catch (e) {
      debugPrint('log set failed: $e');
      if (!mounted) return;
      setState(() => _busy = false);
      _showSnack('Could not save. Try again.');
    }
  }

  Future<void> _finish(String sessionKey) async {
    // _busy stays set until the session is cleared, so a second tap or a
    // late Log set can't add a duplicate row after the finish
    if (_busy || _sets.isEmpty) return;
    setState(() => _busy = true);
    try {
      await DatabaseHelper.instance.finishSession(sessionKey);
    } catch (e) {
      debugPrint('finish session failed: $e');
      if (!mounted) return;
      setState(() => _busy = false);
      _showSnack('Could not save. Try again.');
      return;
    }
    if (!mounted) return;
    final count = _sets.length;
    setState(_endSession);
    _showSnack('Workout finished: $count sets.');
  }

  Future<void> _reset(String sessionKey) async {
    if (_busy) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset workout?'),
        content: Text('This deletes the ${_sets.length} sets logged so far.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      await DatabaseHelper.instance.deleteUnfinishedSets(sessionKey);
    } catch (e) {
      debugPrint('reset session failed: $e');
      if (!mounted) return;
      setState(() => _busy = false);
      _showSnack('Could not save. Try again.');
      return;
    }
    if (!mounted) return;
    setState(_endSession);
  }

  Future<void> _editPlan() async {
    final updated = await Navigator.of(context).push<WorkoutPlan>(
      MaterialPageRoute(builder: (_) => PlanFormScreen(plan: _plan)),
    );
    if (updated == null || !mounted) return;
    setState(() => _plan = updated);
  }

  @override
  Widget build(BuildContext context) {
    final sessionKey = _sessionKey;
    return Scaffold(
      appBar: AppBar(title: Text(_plan.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _PlanHeader(plan: _plan, onEdit: _busy ? null : _editPlan),
          const SizedBox(height: 16),
          if (sessionKey == null)
            FilledButton.icon(
              onPressed: _start,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start'),
            )
          else ...[
            _LogSetForm(
              formKey: _formKey,
              exercise: _exercise,
              reps: _reps,
              weight: _weight,
              busy: _busy,
              onExerciseChanged: (label) => setState(() => _exercise = label),
              onLog: () => _logSet(sessionKey),
            ),
            const SizedBox(height: 16),
            Text(
              '${_sets.length} sets · $_totalReps reps',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            for (final set in _sets) SetRow(key: ValueKey(set.id), log: set),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _busy ? null : () => _reset(sessionKey),
                  child: const Text('Reset'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _busy || _sets.isEmpty
                      ? null
                      : () => _finish(sessionKey),
                  child: const Text('Finish'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PlanHeader extends StatelessWidget {
  const _PlanHeader({required this.plan, required this.onEdit});

  final WorkoutPlan plan;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final note = plan.planNote;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${plan.equipmentTag} · Effort ${plan.effortPreference}/5',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (note != null && note.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(note),
            ],
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit Plan'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogSetForm extends StatelessWidget {
  const _LogSetForm({
    required this.formKey,
    required this.exercise,
    required this.reps,
    required this.weight,
    required this.busy,
    required this.onExerciseChanged,
    required this.onLog,
  });

  final GlobalKey<FormState> formKey;
  final String exercise;
  final TextEditingController reps;
  final TextEditingController weight;
  final bool busy;
  final ValueChanged<String> onExerciseChanged;
  final VoidCallback onLog;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            initialValue: exercise,
            decoration: const InputDecoration(labelText: 'Exercise'),
            items: [
              for (final label in exerciseLabels)
                DropdownMenuItem(value: label, child: Text(label)),
            ],
            onChanged: busy
                ? null
                : (label) {
                    if (label != null) onExerciseChanged(label);
                  },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: reps,
            decoration: const InputDecoration(labelText: 'Reps'),
            keyboardType: TextInputType.number,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: validateReps,
          ),
          const SizedBox(height: 12),
          WeightField(controller: weight),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: busy ? null : onLog,
            child: const Text('Log set'),
          ),
        ],
      ),
    );
  }
}
