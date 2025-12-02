import 'dart:math';
import 'dart:io'; // ✅ NEW: Import for Platform check
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  // Use a singleton pattern to ensure only one instance
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

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
    "Please update today’s tasks.",
    "Don’t forget to check in.",
    "Please enter what you did today.",
    "Take a minute to update your day.",
    "Have you completed any tasks? You can do it now.",
    "Tell us how your day went.",
    "Please record your activities for today.",
    "Ready to check in? Tap here."
  ];

  // --- 1. Initialization ---
  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.local);

    const fln.AndroidInitializationSettings initializationSettingsAndroid =
    fln.AndroidInitializationSettings('@mipmap/ic_launcher');

    const fln.InitializationSettings initializationSettings = fln.InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // ✅ Create notification channel for Android 8.0+
    if (Platform.isAndroid) {
      final fln.AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      _notificationsPlugin.resolvePlatformSpecificImplementation<fln.AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        // Create the notification channel
        const fln.AndroidNotificationChannel channel = fln.AndroidNotificationChannel(
          'motivational_channel_id',
          'Motivational Reminders',
          description: 'Daily positive phrases at random times.',
          importance: fln.Importance.high,
          playSound: true,
          enableVibration: true,
        );

        await androidImplementation.createNotificationChannel(channel);
        debugPrint('✅ Notification channel created successfully');

        // Request notification permission for Android 13+
        final bool? granted = await androidImplementation.requestNotificationsPermission();
        debugPrint('📱 Notification permission granted: $granted');
        
        // Check if exact alarm permission is granted (Android 12+)
        final bool? exactAlarmGranted = await androidImplementation.requestExactAlarmsPermission();
        debugPrint('⏰ Exact alarm permission granted: $exactAlarmGranted');
      }
    }
  }

  // Handle notification tap
  void _onNotificationTapped(fln.NotificationResponse response) {
    debugPrint('🔔 Notification tapped: ${response.payload}');
    // Reschedule the next notification when user taps
    scheduleRandomDailyNotification();
  }

  // --- 2. Scheduling Logic ---
  Future<void> scheduleRandomDailyNotification() async {
    try {
      // 1. Cancel existing notifications to replace them with a new random one
      await _notificationsPlugin.cancelAll();
      debugPrint('🗑️ Cancelled all existing notifications');

      // 2. Generate the random time between 10 AM (10) and 10 PM (22)
      final tz.TZDateTime scheduledTime = _nextInstanceOfRandomTime(10, 22);

      // 3. Select a random phrase
      final String randomPhrase = _phrases[_random.nextInt(_phrases.length)];

      const fln.NotificationDetails notificationDetails = fln.NotificationDetails(
        android: fln.AndroidNotificationDetails(
          'motivational_channel_id',
          'Motivational Reminders',
          channelDescription: 'Daily positive phrases at random times.',
          importance: fln.Importance.high,
          priority: fln.Priority.high,
          playSound: true,
          enableVibration: true,
          enableLights: true,
        ),
      );

      // 4. Schedule the one-time notification
      await _notificationsPlugin.zonedSchedule(
        0, // ID 0 for the single, repeating task
        'Mind Track Check-in',
        randomPhrase,
        scheduledTime,
        notificationDetails,
        androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: fln.UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'daily_reminder',
      );

      debugPrint('✅ Notification scheduled successfully!');
      debugPrint('📅 Scheduled for: $scheduledTime');
      debugPrint('💬 Message: $randomPhrase');
      debugPrint('⏰ Time until notification: ${scheduledTime.difference(tz.TZDateTime.now(tz.local))}');
      
      // Schedule the next notification after this one fires
      _scheduleRescheduling(scheduledTime);
    } catch (e) {
      debugPrint('❌ Error scheduling notification: $e');
    }
  }

  // Schedule a rescheduling task to run after the notification fires
  void _scheduleRescheduling(tz.TZDateTime notificationTime) {
    // Schedule rescheduling 1 minute after the notification should fire
    final tz.TZDateTime rescheduleTime = notificationTime.add(const Duration(minutes: 1));
    
    _notificationsPlugin.zonedSchedule(
      999, // Different ID for the rescheduling notification
      'Rescheduling',
      'Internal rescheduling task',
      rescheduleTime,
      const fln.NotificationDetails(
        android: fln.AndroidNotificationDetails(
          'motivational_channel_id',
          'Motivational Reminders',
          channelDescription: 'Daily positive phrases at random times.',
          importance: fln.Importance.low,
          priority: fln.Priority.low,
          playSound: false,
          enableVibration: false,
          ongoing: false,
          autoCancel: true,
        ),
      ),
      androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: fln.UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'reschedule_trigger',
    ).then((_) {
      debugPrint('🔄 Rescheduling task set for: $rescheduleTime');
    }).catchError((error) {
      debugPrint('⚠️ Error setting rescheduling task: $error');
    });
  }

  // Call this method when app comes to foreground to ensure notifications are still scheduled
  Future<void> ensureNotificationsScheduled() async {
    final List<fln.PendingNotificationRequest> pending =
        await _notificationsPlugin.pendingNotificationRequests();
    
    // If no main notification (ID 0) is pending, reschedule
    final bool hasMainNotification = pending.any((n) => n.id == 0);
    
    if (!hasMainNotification) {
      debugPrint('⚠️ No notification scheduled, rescheduling now...');
      await scheduleRandomDailyNotification();
    } else {
      debugPrint('✅ Notification already scheduled');
    }
  }

  // Test notification - fires immediately
  Future<void> showTestNotification() async {
    const fln.NotificationDetails notificationDetails = fln.NotificationDetails(
      android: fln.AndroidNotificationDetails(
        'motivational_channel_id',
        'Motivational Reminders',
        channelDescription: 'Daily positive phrases at random times.',
        importance: fln.Importance.high,
        priority: fln.Priority.high,
        playSound: true,
        enableVibration: true,
      ),
    );

    await _notificationsPlugin.show(
      1,
      'Test Notification',
      'If you see this, notifications are working! 🎉',
      notificationDetails,
      payload: 'test',
    );
    debugPrint('🧪 Test notification sent');
  }

  // Get pending notifications for debugging
  Future<void> checkPendingNotifications() async {
    final List<fln.PendingNotificationRequest> pending =
        await _notificationsPlugin.pendingNotificationRequests();
    debugPrint('📋 Pending notifications: ${pending.length}');
    for (var notification in pending) {
      debugPrint('  - ID: ${notification.id}, Title: ${notification.title}, Body: ${notification.body}');
    }
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

    final int minutesInWindow = (endHour - startHour) * 60;
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