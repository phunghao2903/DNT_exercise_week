import 'package:flutter/material.dart';

import '../models/weather.dart';
import '../theme/app_theme.dart';

class CurrentWeatherCard extends StatelessWidget {
  const CurrentWeatherCard({super.key, required this.weather});

  final Weather weather;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headline = theme.textTheme.displaySmall?.copyWith(
      fontWeight: FontWeight.bold,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.elementSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current location',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${weather.temperature.toStringAsFixed(1)}°C',
                  style: headline,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weather.conditionLabel,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Wind: ${weather.windSpeed.toStringAsFixed(1)} m/s · ${_windDirectionToCompass(weather.windDirectionDeg)}',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Lat ${weather.latitude.toStringAsFixed(3)}, Lon ${weather.longitude.toStringAsFixed(3)}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Updated at ${_formatTime(weather.time)}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

String _formatTime(DateTime time) {
  final hours = time.hour.toString().padLeft(2, '0');
  final minutes = time.minute.toString().padLeft(2, '0');
  return '$hours:$minutes';
}

String _windDirectionToCompass(int degrees) {
  final directions = <String>['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
  final index = ((degrees % 360) / 45).round() % directions.length;
  return directions[index];
}
