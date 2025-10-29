import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class UnsupportedLocationPlatformException implements Exception {
  static const String defaultMessage =
      'Automatic location is not supported on this platform.';
  final String message;

  const UnsupportedLocationPlatformException([String? message])
      : message = message ?? defaultMessage;

  @override
  String toString() => message;
}

class LocationPermissionDeniedException implements Exception {
  static const String defaultMessage = 'Location permission denied.';
  final String message;

  const LocationPermissionDeniedException([String? message])
      : message = message ?? defaultMessage;

  @override
  String toString() => message;
}

class LocationPermissionDeniedForeverException implements Exception {
  static const String defaultMessage =
      'Location permission permanently denied. Please enable it from settings.';
  final String message;

  const LocationPermissionDeniedForeverException([String? message])
      : message = message ?? defaultMessage;

  @override
  String toString() => message;
}

class LocationServicesDisabledException implements Exception {
  static const String defaultMessage =
      'Location services are disabled. Please enable GPS/location services.';
  final String message;

  const LocationServicesDisabledException([String? message])
      : message = message ?? defaultMessage;

  @override
  String toString() => message;
}

class GeolocatorService {
  Future<Position> getCurrentPosition() async {
    if (!_isPlatformSupported()) {
      throw const UnsupportedLocationPlatformException(
        'Automatic location lookup is only available on Android, iOS, macOS, Windows, and Web builds.',
      );
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServicesDisabledException();
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const LocationPermissionDeniedException();
    }

    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.unableToDetermine) {
      throw const LocationPermissionDeniedForeverException();
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  bool _isPlatformSupported() {
    if (kIsWeb) {
      return true;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return true;
      default:
        return false;
    }
  }
}
