import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../utils/formatters.dart';
import 'timezone_service.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const AndroidNotificationChannel _defaultAndroidChannel =
      AndroidNotificationChannel(
        'reminders_channel',
        'Reminders',
        description: 'Scheduled reminders',
        importance: Importance.max,
      );

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
          defaultPresentAlert: true,
          defaultPresentSound: true,
          defaultPresentBadge: true,
          defaultPresentBanner: true,
          defaultPresentList: true,
        );

    final InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      linux: const LinuxInitializationSettings(defaultActionName: 'Open'),
    );

    await _plugin.initialize(settings);
    await _requestPermissions();
    await _configureAndroidChannel();
    _initialized = true;
  }

  Future<void> scheduleReminder({
    required String id,
    required String title,
    required DateTime when,
  }) async {
    if (!_initialized) {
      throw StateError(
        'NotificationService.initialize() must be called before scheduling.',
      );
    }

    final tz.TZDateTime scheduledDate = TimezoneService.instance
        .fromLocalDateTime(when);

    await _plugin.zonedSchedule(
      _notificationIdFrom(id),
      title,
      'Scheduled for ${dateTimeReadable(when)}',
      scheduledDate,
      _notificationDetails(),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      matchDateTimeComponents: null,
    );
  }

  Future<void> cancelReminder(String id) {
    return _plugin.cancel(_notificationIdFrom(id));
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  Future<void> _requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    await androidImplementation?.requestNotificationsPermission();

    final IOSFlutterLocalNotificationsPlugin? iosImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await iosImplementation?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    final MacOSFlutterLocalNotificationsPlugin? macImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();
    await macImplementation?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _configureAndroidChannel() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(
        _defaultAndroidChannel,
      );
    }
  }

  NotificationDetails _notificationDetails() {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          _defaultAndroidChannel.id,
          _defaultAndroidChannel.name,
          channelDescription: _defaultAndroidChannel.description,
          importance: Importance.max,
          priority: Priority.high,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    return NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  int _notificationIdFrom(String id) => id.hashCode & 0x7fffffff;
}
