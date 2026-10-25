import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../helper/validators.dart';
import '../models/training_log.dart';
import '../widgets/empty_state.dart';
import '../widgets/set_row.dart';
import '../widgets/stat_tile.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<HistorySet>? _sets;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sets = await DatabaseHelper.instance.finishedSets();
    if (!mounted) return;
    setState(() => _sets = sets);
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _edit(HistorySet set) async {
    final updated = await showDialog<TrainingLog>(
      context: context,
      builder: (_) => _EditSetDialog(log: set.log),
    );
    final sets = _sets;
    if (updated == null || sets == null || !mounted) return;
    setState(() {
      final index = sets.indexWhere((s) => s.log.id == updated.id);
      if (index >= 0) sets[index] = (log: updated, planTitle: set.planTitle);
    });
  }

  // swipe and the Delete button share this, so a failed write keeps the row
  // either way; returns true only once the row is gone
  Future<bool> _delete(HistorySet set) async {
    if (_busy) return false;
    final log = set.log;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete set?'),
        content: Text(
          'Delete ${log.exerciseLabel}, ${log.repetitions} reps? '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return false;

    setState(() => _busy = true);
    try {
      // rows come from the database, so the id is always set
      await DatabaseHelper.instance.deleteLog(log.id!);
    } catch (e) {
      debugPrint('delete set failed: $e');
      if (!mounted) return false;
      setState(() => _busy = false);
      _showSnack('Could not save. Try again.');
      return false;
    }
    if (!mounted) return true;
    setState(() {
      _sets?.removeWhere((s) => s.log.id == log.id);
      _busy = false;
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final sets = _sets;
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: switch (sets) {
        null => const Center(child: CircularProgressIndicator()),
        [] => const EmptyState(
          message: 'No sessions yet.',
          icon: Icons.history,
        ),
        _ => _SessionList(
          sets: sets,
          busy: _busy,
          onEdit: _edit,
          onDelete: _delete,
        ),
      },
    );
  }
}

class _SessionList extends StatelessWidget {
  const _SessionList({
    required this.sets,
    required this.busy,
    required this.onEdit,
    required this.onDelete,
  });

  final List<HistorySet> sets;
  final bool busy;
  final ValueChanged<HistorySet> onEdit;
  final Future<bool> Function(HistorySet) onDelete;

  @override
  Widget build(BuildContext context) {
    // sets arrive sorted by session, and map literals keep insertion order
    final sessions = <String, List<HistorySet>>{};
    for (final set in sets) {
      sessions.putIfAbsent(set.log.sessionKey, () => []).add(set);
    }
    final totalReps = sets.fold(0, (sum, set) => sum + set.log.repetitions);
    final localizations = MaterialLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: StatTile(
                label: 'Workouts finished',
                value: '${sessions.length}',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StatTile(label: 'Total reps', value: '$totalReps'),
            ),
          ],
        ),
        for (final MapEntry(key: sessionKey, value: group)
            in sessions.entries) ...[
          const SizedBox(height: 16),
          Text(
            '${_sessionDate(localizations, sessionKey)} · '
            '${group.first.planTitle}',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          for (final set in group)
            Dismissible(
              key: ValueKey(set.log.id),
              direction: busy
                  ? DismissDirection.none
                  : DismissDirection.endToStart,
              confirmDismiss: (_) => onDelete(set),
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                color: Theme.of(context).colorScheme.errorContainer,
                child: const Icon(Icons.delete_outline),
              ),
              child: SetRow(
                log: set.log,
                onEdit: busy ? null : () => onEdit(set),
                onDelete: busy ? null : () => onDelete(set),
              ),
            ),
        ],
      ],
    );
  }
}

// the key is the epoch milliseconds from when Start was pressed
String _sessionDate(MaterialLocalizations localizations, String sessionKey) {
  final started = DateTime.fromMillisecondsSinceEpoch(int.parse(sessionKey));
  return localizations.formatMediumDate(started);
}

class _EditSetDialog extends StatefulWidget {
  const _EditSetDialog({required this.log});

  final TrainingLog log;

  @override
  State<_EditSetDialog> createState() => _EditSetDialogState();
}

class _EditSetDialogState extends State<_EditSetDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _reps = TextEditingController(text: '${widget.log.repetitions}');
  late String _exercise = widget.log.exerciseLabel;
  bool _saving = false;

  @override
  void dispose() {
    _reps.dispose();
    super.dispose();
  }

  // the write happens here rather than in the screen so a failure keeps the
  // dialog open with the user's input
  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final updated = widget.log.copyWith(
      exerciseLabel: _exercise,
      repetitions: int.parse(_reps.text.trim()),
    );
    try {
      await DatabaseHelper.instance.updateLog(updated);
      if (!mounted) return;
      Navigator.of(context).pop(updated);
    } catch (e) {
      debugPrint('update set failed: $e');
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit set'),
      scrollable: true,
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _exercise,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Exercise'),
              items: [
                for (final label in exerciseLabels)
                  DropdownMenuItem(value: label, child: Text(label)),
              ],
              onChanged: _saving
                  ? null
                  : (label) {
                      if (label != null) setState(() => _exercise = label);
                    },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _reps,
              decoration: const InputDecoration(labelText: 'Reps'),
              keyboardType: TextInputType.number,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: validateReps,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
