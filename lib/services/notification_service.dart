import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln; // Added 'as fln'
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  // Use a singleton pattern to ensure only one instance
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Used the fln prefix
  final fln.FlutterLocalNotificationsPlugin _notificationsPlugin = fln.FlutterLocalNotificationsPlugin();
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
  ];

  // --- 1. Initialization ---
  Future<void> init() async {
    tz.initializeTimeZones();
    // Set the local time zone (crucial for time-based scheduling)
    tz.setLocalLocation(tz.local);

    // Used the fln prefix
    const fln.AndroidInitializationSettings initializationSettingsAndroid =
    fln.AndroidInitializationSettings('@mipmap/ic_launcher');

    const fln.InitializationSettings initializationSettings = fln.InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  // --- 2. Scheduling Logic ---
  Future<void> scheduleRandomDailyNotification() async {
    // 1. Cancel existing notifications to replace them with a new random one
    await _notificationsPlugin.cancelAll();

    // 2. Generate the random time between 10 AM (10) and 10 PM (22)
    final tz.TZDateTime scheduledTime = _nextInstanceOfRandomTime(10, 22);

    // 3. Select a random phrase
    final String randomPhrase = _phrases[_random.nextInt(_phrases.length)];

    // Used the fln prefix for all NotificationDetails components
    const fln.NotificationDetails notificationDetails = fln.NotificationDetails(
      android: fln.AndroidNotificationDetails(
        'motivational_channel_id',
        'Motivational Reminders',
        channelDescription: 'Daily positive phrases at random times.',
        importance: fln.Importance.high,
      ),
    );

    // 4. Schedule the one-time notification
    await _notificationsPlugin.zonedSchedule(
      0, // ID 0 for the single, repeating task
      'Mind Track Check-in',
      randomPhrase,
      scheduledTime,
      notificationDetails,
      androidAllowWhileIdle: true,
      // Used the fln prefix
      uiLocalNotificationDateInterpretation: fln.UILocalNotificationDateInterpretation.absoluteTime,
      // NOTE: matchDateTimeComponents is NOT used because the time is random daily.
      // The app must re-schedule this every time it is opened.
    );

    debugPrint('Notification scheduled for: $scheduledTime with message: $randomPhrase');
  }

  // Helper to calculate the next occurrence of a random time within the range
  tz.TZDateTime _nextInstanceOfRandomTime(int startHour, int endHour) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
    );

    // Total duration of the window in minutes (e.g., 10:00 to 22:00 is 12 hours * 60 = 720 minutes)
    final int minutesInWindow = (endHour - startHour) * 60;

    // Generate a random minute offset within the window
    final int randomOffsetInMinutes = _random.nextInt(minutesInWindow);

    // Calculate the target time: Today at startHour + randomOffset
    scheduledDate = scheduledDate.add(Duration(hours: startHour, minutes: randomOffsetInMinutes));

    // If the scheduled time is *before* the current moment, schedule it for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }
}