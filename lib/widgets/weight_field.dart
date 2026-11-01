import 'package:flutter/material.dart';

import '../helper/validators.dart';

/// The optional weight box, shared with the History edit dialog.
///
/// The workout screen leaves it filled between sets, since most sets repeat
/// the same weight.
class WeightField extends StatelessWidget {
  const WeightField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Weight (lb)',
        helperText: 'Optional. Leave blank for bodyweight.',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validateWeight,
    );
  }
}
