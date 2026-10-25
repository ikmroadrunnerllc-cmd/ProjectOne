import 'package:flutter/material.dart';

class EffortSlider extends StatelessWidget {
  const EffortSlider({
    super.key,
    required this.label,
    required this.effort,
    required this.onChanged,
    this.onChangeEnd,
  });

  final String label;
  final int effort;
  final ValueChanged<int>? onChanged;
  final ValueChanged<int>? onChangeEnd;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    final onChangeEnd = this.onChangeEnd;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('$label: $effort', style: Theme.of(context).textTheme.titleSmall),
        Slider(
          value: effort.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          label: '$effort',
          onChanged: onChanged == null
              ? null
              : (value) => onChanged(value.round()),
          onChangeEnd: onChangeEnd == null
              ? null
              : (value) => onChangeEnd(value.round()),
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text('1 Easy'), Text('5 Hard')],
        ),
      ],
    );
  }
}
