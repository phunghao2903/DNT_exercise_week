class HourlyPoint {
  final DateTime time;
  final double temperature;
  final double? apparentTemperature;
  final int? humidity;

  const HourlyPoint({
    required this.time,
    required this.temperature,
    this.apparentTemperature,
    this.humidity,
  });
}
