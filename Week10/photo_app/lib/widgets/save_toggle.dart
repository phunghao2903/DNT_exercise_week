import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SaveToggle extends StatelessWidget {
  const SaveToggle({
    super.key,
    required this.notifier,
    required this.onChanged,
  });

  final ValueListenable<bool> notifier;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ValueListenableBuilder<bool>(
        valueListenable: notifier,
        builder: (context, value, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Save locally',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
              ),
            ],
          );
        },
      ),
    );
  }
}
