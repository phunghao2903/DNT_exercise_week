import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/models/hourly_point.dart';
import 'package:weather_app/models/weather.dart';
import 'package:weather_app/widgets/current_weather_card.dart';

void main() {
  testWidgets(
    'CurrentWeatherCard renders weather information',
    (tester) async {
      final weather = Weather(
        latitude: 51.5,
        longitude: -0.12,
        time: DateTime(2024, 1, 1, 12, 30),
        temperature: 18.2,
        windSpeed: 4.5,
        windDirectionDeg: 90,
        weatherCode: 0,
        conditionLabel: 'Clear sky',
        hourly: <HourlyPoint>[],
      );

      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(
          body: CurrentWeatherCard(weather: weather),
        ),
      ));

      expect(find.textContaining('18.2°C'), findsOneWidget);
      expect(find.text('Clear sky'), findsOneWidget);
      expect(find.textContaining('Lat'), findsOneWidget);
    },
  );
}
