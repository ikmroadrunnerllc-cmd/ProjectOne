import 'package:flutter/material.dart';

import '../models/training_log.dart';

class SetRow extends StatelessWidget {
  const SetRow({super.key, required this.log, this.onEdit, this.onDelete});

  final TrainingLog log;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(log.exerciseLabel),
      subtitle: Text('${log.repetitions} reps'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onEdit != null)
            Semantics(
              label: 'Edit ${log.exerciseLabel} set',
              excludeSemantics: true,
              button: true,
              onTap: onEdit,
              child: IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: onEdit,
              ),
            ),
          if (onDelete != null)
            Semantics(
              label: 'Delete ${log.exerciseLabel} set',
              excludeSemantics: true,
              button: true,
              onTap: onDelete,
              child: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
              ),
            ),
        ],
      ),
    );
  }
}
