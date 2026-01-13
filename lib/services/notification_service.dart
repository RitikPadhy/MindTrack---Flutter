import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final fln.FlutterLocalNotificationsPlugin _plugin =
  fln.FlutterLocalNotificationsPlugin();
  final Random _random = Random();

  // Your list of motivational phrases
  final List<String> _phrases = [
    "Tiny actions, consistent effort, that’s where strength grows.",
    "Celebrate every check-in—these moments are shaping your days.",
    "Consistency isn’t about speed. It’s about returning, every day.",
    "Even slow progress is still progress; breathe and continue.",
    "You’ve created consistency. That is powerful, and it belongs to you.",
    "Notice how far you’ve come—your time, energy, and hope are taking shape.",
    "Progress lives in these everyday moments of doing.",
    "A small step today matters. Keep going.",
    "Pause and check in, how can you take care of yourself right now?",
    "You’re halfway through—every effort counts.",
    "Even a brief moment of meaningful activity lifts the day.",
    "Even small efforts shape your life. Be proud of today’s steps.",
    "Please update today’s tasks.",
    "Don’t forget to check in.",
    "Please enter what you did today.",
    "Take a minute to update your day.",
    "Have you completed any tasks? You can do it now.",
    "Tell us how your day went.",
    "Please record your activities for today.",
    "Ready to check in? Tap here."
  ];

  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.local);

    const androidInit = fln.AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = fln.InitializationSettings(android: androidInit);

    await _plugin.initialize(initSettings);

    final android =
    _plugin.resolvePlatformSpecificImplementation<
        fln.AndroidFlutterLocalNotificationsPlugin>();

    if (android != null) {
      const channel = fln.AndroidNotificationChannel(
        'daily_reminder',
        'Daily Reminder',
        description: 'Daily check-in reminder',
        importance: fln.Importance.high,
      );

      await android.createNotificationChannel(channel);

      final granted = await android.requestNotificationsPermission();
      debugPrint('🔔 Notification permission: $granted');

      final exactGranted = await android.requestExactAlarmsPermission();
      debugPrint('⏰ Exact alarm permission: $exactGranted');
    }
  }

  Future<void> ensureNotificationScheduled() async {
    debugPrint('🔥 TEST ensureNotificationScheduled CALLED');

    await _plugin.cancel(0);
    debugPrint('🔥 TEST cancelled notification 0');

    await _scheduleTomorrow();
  }

  Future<void> _scheduleTomorrow() async {
    final now = tz.TZDateTime.now(tz.local);

    // Random hour between 10 AM (10) and 10 PM (22)
    final randomHour = 10 + _random.nextInt(13); // 10..22 inclusive
    final randomMinute = _random.nextInt(60); // 0..59

    // Schedule for today if the time is still in the future, otherwise schedule for tomorrow
    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      randomHour,
      randomMinute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      0,
      '', // empty title
      _phrases[_random.nextInt(_phrases.length)],
      scheduled,
      const fln.NotificationDetails(
        android: fln.AndroidNotificationDetails(
          'daily_reminder',
          'Daily Reminder',
          importance: fln.Importance.high,
          priority: fln.Priority.high,
        ),
      ),
      androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      fln.UILocalNotificationDateInterpretation.absoluteTime,
    );

    debugPrint('✅ Notification scheduled for $scheduled');
  }

  Future<void> showTestNotification() async {
    await _plugin.show(
      99,
      'Test',
      'Notifications are working 🎉',
      const fln.NotificationDetails(
        android: fln.AndroidNotificationDetails(
          'daily_reminder',
          'Daily Reminder',
          importance: fln.Importance.high,
        ),
      ),
    );
  }
}