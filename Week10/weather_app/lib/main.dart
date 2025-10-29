import 'package:flutter/material.dart';

import 'screens/weather_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WeatherAppGeo());
}

class WeatherAppGeo extends StatelessWidget {
  const WeatherAppGeo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'weather_app_geo',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const WeatherScreen(),
    );
  }
}
