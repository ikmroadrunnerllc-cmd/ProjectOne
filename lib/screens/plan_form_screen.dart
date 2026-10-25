import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/workout_plan.dart';
import '../widgets/effort_slider.dart';

class PlanFormScreen extends StatefulWidget {
  const PlanFormScreen({super.key, this.plan, this.defaultEffort = 3});

  final WorkoutPlan? plan;

  /// Starting effort for a new plan, from settings.
  ///
  /// Ignored when editing, since the plan already has one.
  final int defaultEffort;

  @override
  State<PlanFormScreen> createState() => _PlanFormScreenState();
}

class _PlanFormScreenState extends State<PlanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.plan?.title);
  late final _note = TextEditingController(text: widget.plan?.planNote);
  late String _equipment = widget.plan?.equipmentTag ?? equipmentTags.first;
  late int _effort = widget.plan?.effortPreference ?? widget.defaultEffort;
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  void _showSaveError() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Could not save. Try again.')));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final note = _note.text.trim();
    var plan = WorkoutPlan(
      id: widget.plan?.id,
      title: _title.text.trim(),
      equipmentTag: _equipment,
      planNote: note.isEmpty ? null : note,
      effortPreference: _effort,
    );
    try {
      if (plan.id == null) {
        plan = plan.copyWith(
          id: await DatabaseHelper.instance.insertPlan(plan),
        );
      } else {
        await DatabaseHelper.instance.updatePlan(plan);
      }
    } catch (e) {
      debugPrint('save plan failed: $e');
      if (!mounted) return;
      setState(() => _saving = false);
      _showSaveError();
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pop(plan);
  }

  Future<void> _delete(WorkoutPlan plan) async {
    final helper = DatabaseHelper.instance;
    // only saved plans reach edit mode, so the id is always set
    final id = plan.id!;
    final setCount = await helper.setCountForPlan(id);
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text('Delete ${plan.title} and its $setCount logged sets?'),
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
    if (confirmed != true || !mounted) return;

    setState(() => _saving = true);
    try {
      await helper.deletePlan(id);
    } catch (e) {
      debugPrint('delete plan failed: $e');
      if (!mounted) return;
      setState(() => _saving = false);
      _showSaveError();
      return;
    }
    if (!mounted) return;
    // the workout screen under this form shows the deleted plan, so leave both
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    return Scaffold(
      appBar: AppBar(title: Text(plan == null ? 'New Plan' : 'Edit Plan')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Title'),
              maxLength: 40,
              textCapitalization: TextCapitalization.sentences,
              validator: _validateTitle,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _equipment,
              decoration: const InputDecoration(labelText: 'Equipment'),
              items: [
                for (final tag in equipmentTags)
                  DropdownMenuItem(value: tag, child: Text(tag)),
              ],
              onChanged: (tag) {
                if (tag != null) setState(() => _equipment = tag);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _note,
              decoration: const InputDecoration(labelText: 'Note (optional)'),
              minLines: 1,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            EffortSlider(
              label: 'Effort',
              effort: _effort,
              onChanged: (effort) => setState(() => _effort = effort),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _saving ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: const Text('Save'),
                ),
              ],
            ),
            if (plan != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _saving ? null : () => _delete(plan),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete plan'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String? _validateTitle(String? raw) {
  final title = raw?.trim() ?? '';
  if (title.isEmpty) return 'Enter a title.';
  if (title.length > 40) return 'Keep the title to 40 characters.';
  return null;
}
