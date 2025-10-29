import 'package:flutter/foundation.dart';
import 'package:flutter_native_timezone_updated_gradle/flutter_native_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class TimezoneService {
  TimezoneService._();

  static final TimezoneService instance = TimezoneService._();

  bool _initialized = false;
  String? _timezoneName;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    tzdata.initializeTimeZones();
    try {
      _timezoneName = await FlutterNativeTimezone.getLocalTimezone();
      final tz.Location location = tz.getLocation(_timezoneName!);
      tz.setLocalLocation(location);
    } on Exception catch (error) {
      debugPrint('Failed to load local timezone: $error. Falling back to UTC.');
      tz.setLocalLocation(tz.UTC);
      _timezoneName = 'UTC';
    }

    _initialized = true;
  }

  tz.TZDateTime fromLocalDateTime(DateTime dateTime) {
    if (!_initialized) {
      throw StateError(
        'TimezoneService.initialize() must be called before creating TZDateTime.',
      );
    }
    return tz.TZDateTime.from(dateTime, tz.local);
  }

  String? get timezoneName => _timezoneName;
}
