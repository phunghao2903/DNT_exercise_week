import 'hourly_point.dart';

class Weather {
  final double latitude;
  final double longitude;
  final DateTime time;
  final double temperature;
  final double windSpeed;
  final int windDirectionDeg;
  final int weatherCode;
  final String conditionLabel;
  final List<HourlyPoint> hourly;

  const Weather({
    required this.latitude,
    required this.longitude,
    required this.time,
    required this.temperature,
    required this.windSpeed,
    required this.windDirectionDeg,
    required this.weatherCode,
    required this.conditionLabel,
    required this.hourly,
  });
}
