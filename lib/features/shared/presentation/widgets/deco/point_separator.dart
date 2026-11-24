import 'package:flutter/material.dart';

class PointSeparator extends StatelessWidget {
  const PointSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      '·',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 16.0,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(150),
          ),
    );
  }
}
