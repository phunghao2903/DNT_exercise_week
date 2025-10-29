import 'package:flutter/material.dart';

import '../models/hourly_point.dart';
import '../theme/app_theme.dart';

class HourlyStrip extends StatelessWidget {
  const HourlyStrip({super.key, required this.points});

  final List<HourlyPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final cardColor = theme.colorScheme.surfaceContainerHighest;

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 2),
        itemBuilder: (context, index) {
          final point = points[index];
          return Container(
            width: 100,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(AppTheme.cardRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatTime(point.time),
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  '${point.temperature.toStringAsFixed(1)}°C',
                  style: theme.textTheme.titleMedium,
                ),
                if (point.apparentTemperature != null)
                  Text(
                    'Feels ${point.apparentTemperature!.toStringAsFixed(1)}°',
                    style: theme.textTheme.bodySmall,
                  ),
                if (point.humidity != null)
                  Text(
                    '${point.humidity}% RH',
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          );
        },
        separatorBuilder: (context, _) =>
            const SizedBox(width: AppTheme.elementSpacing),
        itemCount: points.length,
      ),
    );
  }

  String _formatTime(DateTime date) {
    final hours = date.hour.toString().padLeft(2, '0');
    final minutes = date.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }
}
