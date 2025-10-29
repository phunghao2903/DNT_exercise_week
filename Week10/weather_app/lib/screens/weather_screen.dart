import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/weather.dart';
import '../services/geolocator_service.dart';
import '../services/weather_api.dart';
import '../theme/app_theme.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/error_view.dart';
import '../widgets/hourly_strip.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late final GeolocatorService _geolocatorService;
  late final WeatherApi _weatherApi;
  Future<Weather>? _weatherFuture;

  @override
  void initState() {
    super.initState();
    _geolocatorService = GeolocatorService();
    _weatherApi = WeatherApi();
    _weatherFuture = _loadWeather();
  }

  Future<Weather> _loadWeather() async {
    final position = await _geolocatorService.getCurrentPosition();
    return _weatherApi.fetchWeather(position.latitude, position.longitude);
  }

  Future<void> _refresh() async {
    final future = _loadWeather();
    setState(() {
      _weatherFuture = future;
    });
    await future;
  }

  void _retry() {
    setState(() {
      _weatherFuture = _loadWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Weather'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        displacement: 36,
        child: FutureBuilder<Weather>(
          future: _weatherFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoading();
            }

            if (snapshot.hasError) {
              return _buildError(snapshot.error);
            }

            final weather = snapshot.data;
            if (weather == null) {
              return _buildError(
                const WeatherApiException('No weather data available.'),
              );
            }

            return _buildContent(weather);
          },
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(
          height: 320,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ],
    );
  }

  Widget _buildError(Object? error) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
      children: [
        SizedBox(
          height: 320,
          child: Center(
            child: ErrorView(
              message: _mapErrorMessage(error),
              onRetry: _retry,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(Weather weather) {
    return ListView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.screenPadding,
        vertical: AppTheme.screenPadding,
      ),
      children: [
        CurrentWeatherCard(weather: weather),
        const SizedBox(height: AppTheme.elementSpacing),
        Text(
          'Next hours',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        HourlyStrip(points: weather.hourly),
      ],
    );
  }

  String _mapErrorMessage(Object? error) {
    if (error is UnsupportedLocationPlatformException) {
      return 'Automatic location lookup is not available on this platform. Please run the app on Android, iOS, macOS, Windows, or the Web.';
    }
    if (error is LocationPermissionDeniedForeverException) {
      return error.message;
    }
    if (error is LocationPermissionDeniedException) {
      return error.message;
    }
    if (error is LocationServicesDisabledException) {
      return error.message;
    }
    if (error is WeatherApiException) {
      return error.message;
    }
    if (error is PermissionDefinitionsNotFoundException) {
      return 'Location permission is not defined in platform manifests.';
    }
    return 'Something went wrong. Please try again.';
  }
}
