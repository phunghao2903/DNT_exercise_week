import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/hourly_point.dart';
import '../models/weather.dart';

class WeatherApiException implements Exception {
  final String message;

  const WeatherApiException(this.message);

  @override
  String toString() => message;
}

class WeatherApi {
  WeatherApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Weather> fetchWeather(double latitude, double longitude) async {
    final uri = Uri.https(
      'api.open-meteo.com',
      '/v1/forecast',
      <String, String>{
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current_weather': 'true',
        'hourly': 'temperature_2m,relativehumidity_2m,apparent_temperature',
        'timezone': 'auto',
      },
    );

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw WeatherApiException(
        'Failed to fetch weather. Code: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final current = decoded['current_weather'] as Map<String, dynamic>?;
    final hourly = decoded['hourly'] as Map<String, dynamic>?;

    if (current == null || hourly == null) {
      throw const WeatherApiException('Malformed weather response.');
    }

    final hourlyPoints = _parseHourly(hourly);

    final weatherCode = (current['weathercode'] as num).toInt();

    return Weather(
      latitude: (decoded['latitude'] as num).toDouble(),
      longitude: (decoded['longitude'] as num).toDouble(),
      time: DateTime.parse(current['time'] as String),
      temperature: (current['temperature'] as num).toDouble(),
      windSpeed: (current['windspeed'] as num).toDouble(),
      windDirectionDeg: (current['winddirection'] as num).round(),
      weatherCode: weatherCode,
      conditionLabel: describeWeatherCode(weatherCode),
      hourly: hourlyPoints,
    );
  }

  List<HourlyPoint> _parseHourly(Map<String, dynamic> hourly) {
    final times = (hourly['time'] as List<dynamic>? ?? List.empty())
        .cast<String>();
    final temperatures =
        (hourly['temperature_2m'] as List<dynamic>? ?? List.empty())
            .cast<num>();
    final apparentTemperatures =
        (hourly['apparent_temperature'] as List<dynamic>? ?? List.empty())
            .cast<num>();
    final humidityValues =
        (hourly['relativehumidity_2m'] as List<dynamic>? ?? List.empty())
            .cast<num>();

    final length =
        times.length < temperatures.length ? times.length : temperatures.length;
    final limit = length < 12 ? length : 12;

    final List<HourlyPoint> points = <HourlyPoint>[];
    for (var i = 0; i < limit; i++) {
      points.add(
        HourlyPoint(
          time: DateTime.parse(times[i]),
          temperature: temperatures[i].toDouble(),
          apparentTemperature: i < apparentTemperatures.length
              ? apparentTemperatures[i].toDouble()
              : null,
          humidity:
              i < humidityValues.length ? humidityValues[i].round() : null,
        ),
      );
    }

    return points;
  }

  String describeWeatherCode(int code) {
    if (code == 0) return 'Clear sky';
    if (code >= 1 && code <= 3) return 'Partly cloudy';
    if (code == 45 || code == 48) return 'Fog';
    if (code >= 51 && code <= 57) return 'Drizzle';
    if (code >= 61 && code <= 67) return 'Rain';
    if (code >= 71 && code <= 77) return 'Snow';
    if (code >= 80 && code <= 82) return 'Rain showers';
    if (code >= 95 && code <= 99) return 'Thunderstorm';
    return 'Unknown';
  }
}
