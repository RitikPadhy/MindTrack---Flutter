import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mind_track/l10n/app_localizations.dart';
import '../../services/api_service.dart';

// Global notifications instance
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

class ContentPage4 extends StatefulWidget {
  const ContentPage4({super.key});

  @override
  State<ContentPage4> createState() => _ContentPage4State();
}

class _ContentPage4State extends State<ContentPage4> {
  // 🎚️ Slider states
  double energy = 0;
  double satisfaction = 0;
  double happiness = 0;
  double proud = 0;
  double busy = 0;

  // ✅ Feedback text
  String feedbackText = "";
  final TextEditingController _feedbackController = TextEditingController();

  // 🗓️ SharedPreferences & API
  DateTime? _createdAt;
  late SharedPreferences _prefs;
  final ApiService _api = ApiService();

  static const String _createdAtStorageKey = 'user_created_at';

  Timer? _weeklyTimer;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _initPrefsAndLoad();
    _feedbackController.addListener(_updateFeedbackText);

    // 🔄 Periodic weekly check every hour
    _weeklyTimer = Timer.periodic(const Duration(hours: 1), (_) async {
      await _syncAllUnsyncedWeeks();
    });
  }

  @override
  void dispose() {
    _feedbackController.removeListener(_updateFeedbackText);
    _feedbackController.dispose();
    _weeklyTimer?.cancel();
    super.dispose();
  }

  void _updateFeedbackText() {
    final newText = _feedbackController.text;
    if (feedbackText != newText) {
      setState(() => feedbackText = newText);
      final currentWeek = _calculateWeekNumber(_createdAt!);
      _prefs.setString(_getWeekStorageKey(currentWeek, 'text'), newText);
    }
  }

  // ---------------- Notifications ----------------
  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false);

    const InitializationSettings settings =
    InitializationSettings(android: androidSettings, iOS: iosSettings);

    await flutterLocalNotificationsPlugin.initialize(settings);
  }

  Future<void> _showCompletionNotification(int weekNumber) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'weekly_feedback_channel',
      'Weekly Feedback Notifications',
      channelDescription: 'Notifications for weekly feedback submissions.',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      AppLocalizations.of(context).translate('feedback_complete'),
      '${AppLocalizations.of(context).translate('thanks_for_feedback')} $weekNumber ${AppLocalizations.of(context).translate('successfully_saved')}',
      platformDetails,
      payload: 'feedback_synced',
    );
  }

  // ---------------- Initialization ----------------
  Future<void> _initPrefsAndLoad() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadCreatedAt();
    await _loadCurrentWeekData();
    await _syncAllUnsyncedWeeks(); // sync old weeks if needed
    if (mounted) setState(() {});
  }

  Future<void> _loadCreatedAt() async {
    final storedCreatedAtInt = _prefs.getInt(_createdAtStorageKey);

    if (storedCreatedAtInt != null && storedCreatedAtInt > 0) {
      final fullDate = DateTime.fromMillisecondsSinceEpoch(storedCreatedAtInt);
      _createdAt = DateTime(fullDate.year, fullDate.month, fullDate.day);
    }
  }

  Future<void> _loadCurrentWeekData() async {
    if (_createdAt == null) return;
    final currentWeek = _calculateWeekNumber(_createdAt!);

    setState(() {
      energy =
          _prefs.getDouble(_getWeekStorageKey(currentWeek, 'energy')) ?? 0;
      satisfaction =
          _prefs.getDouble(_getWeekStorageKey(currentWeek, 'satisfaction')) ?? 0;
      happiness =
          _prefs.getDouble(_getWeekStorageKey(currentWeek, 'happiness')) ?? 0;
      proud = _prefs.getDouble(_getWeekStorageKey(currentWeek, 'proud')) ?? 0;
      busy = _prefs.getDouble(_getWeekStorageKey(currentWeek, 'busy')) ?? 0;
      feedbackText =
          _prefs.getString(_getWeekStorageKey(currentWeek, 'text')) ?? "";
      _feedbackController.text = feedbackText;
    });
  }

  // ---------------- Weekly Storage Helpers ----------------
  String _getWeekStorageKey(int weekNumber, String type) =>
      'feedback_week_${weekNumber}_$type';
  String _getWeekSyncedKey(int weekNumber) =>
      'feedback_week_${weekNumber}_synced';

  int _calculateWeekNumber(DateTime startDate) {
    final today = DateTime.now();
    final deltaDays =
        DateTime(today.year, today.month, today.day).difference(startDate).inDays;
    int weekNum = (deltaDays ~/ 7) + 1;
    if (weekNum < 1) weekNum = 1;
    return weekNum;
  }

  // ---------------- Slider Handlers ----------------
  void _updateEnergy(double v) {
    setState(() => energy = v);
    final currentWeek = _calculateWeekNumber(_createdAt!);
    _prefs.setDouble(_getWeekStorageKey(currentWeek, 'energy'), v);
  }

  void _updateSatisfaction(double v) {
    setState(() => satisfaction = v);
    final currentWeek = _calculateWeekNumber(_createdAt!);
    _prefs.setDouble(_getWeekStorageKey(currentWeek, 'satisfaction'), v);
  }

  void _updateHappiness(double v) {
    setState(() => happiness = v);
    final currentWeek = _calculateWeekNumber(_createdAt!);
    _prefs.setDouble(_getWeekStorageKey(currentWeek, 'happiness'), v);
  }

  void _updateProud(double v) {
    setState(() => proud = v);
    final currentWeek = _calculateWeekNumber(_createdAt!);
    _prefs.setDouble(_getWeekStorageKey(currentWeek, 'proud'), v);
  }

  void _updateBusy(double v) {
    setState(() => busy = v);
    final currentWeek = _calculateWeekNumber(_createdAt!);
    _prefs.setDouble(_getWeekStorageKey(currentWeek, 'busy'), v);
  }

  // ---------------- Sync Unsynced Weeks ----------------
  Future<void> _syncAllUnsyncedWeeks() async {
    if (_createdAt == null) return;

    final today = DateTime.now();
    final start = DateTime(_createdAt!.year, _createdAt!.month, _createdAt!.day);
    final daysSinceStart =
        DateTime(today.year, today.month, today.day).difference(start).inDays;

    final currentWeek = (daysSinceStart ~/ 7) + 1;

    // Only weeks BEFORE the current one are eligible
    final lastCompletedWeek = currentWeek - 1;
    if (lastCompletedWeek < 1) return;

    for (int week = 1; week <= lastCompletedWeek; week++) {
      final isSynced = _prefs.getBool(_getWeekSyncedKey(week)) ?? false;
      if (!isSynced) {
        await _syncWeek(week);
      }
    }
  }

  Future<void> _syncWeek(int weekNumber) async {
    try {
      await _api.updateWeeklyFeedback(
        weekNumber: weekNumber,
        energyLevels: (_prefs.getDouble(_getWeekStorageKey(weekNumber, 'energy')) ?? 0) / 10,
        satisfaction: (_prefs.getDouble(_getWeekStorageKey(weekNumber, 'satisfaction')) ?? 0) / 10,
        happiness: (_prefs.getDouble(_getWeekStorageKey(weekNumber, 'happiness')) ?? 0) / 10,
        proudOfAchievements: (_prefs.getDouble(_getWeekStorageKey(weekNumber, 'proud')) ?? 0) / 10,
        howBusy: (_prefs.getDouble(_getWeekStorageKey(weekNumber, 'busy')) ?? 0) / 10,
        feedbackText: _prefs.getString(_getWeekStorageKey(weekNumber, 'text')) ?? '',
      );

      await _prefs.setBool(_getWeekSyncedKey(weekNumber), true);
      _showCompletionNotification(weekNumber);

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${l10n.translate('feedback_saved')} $weekNumber ${l10n.translate('saved_and_retained')}')));
      }
    } catch (e) {
      debugPrint("Failed to sync week $weekNumber: $e");
    }
  }

  // ---------------- Build UI ----------------
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();

    String weekRange = 'Loading week range...';
    String creationDate = 'Loading member status...';

    if (_createdAt != null) {
      final startDate = _createdAt!;
      final daysSinceStart = DateTime(now.year, now.month, now.day)
          .difference(startDate)
          .inDays;
      final currentWeekIndex = (daysSinceStart / 7).floor();
      final weekStart = startDate.add(Duration(days: currentWeekIndex * 7));
      final weekEnd = weekStart.add(const Duration(days: 6));

      weekRange =
      '${DateFormat('d MMMM').format(weekStart)} – ${DateFormat('d MMMM').format(weekEnd)}';
      creationDate =
      '${l10n.translate('member_since')} ${DateFormat('MMMM d, yyyy').format(_createdAt!)} | ${l10n.translate('week')} ${_calculateWeekNumber(startDate)}';
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF9FE2BF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n.translate('weekly_feedback'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                creationDate,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              Text(
                weekRange,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xA6000000)),
              ),
              const SizedBox(height: 16),
              _buildInteractiveBar(
                  l10n.translate('energy_levels'), energy, _updateEnergy),
              _buildInteractiveBar(
                  l10n.translate('satisfaction'), satisfaction, _updateSatisfaction),
              _buildInteractiveBar(
                  l10n.translate('happiness'), happiness, _updateHappiness),
              _buildInteractiveBar(
                  l10n.translate('proud_of_achievements'), proud, _updateProud),
              _buildInteractiveBar(
                  l10n.translate('how_busy'), busy, _updateBusy),
              const SizedBox(height: 16),
              _buildFeedbackTextBox(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveBar(
      String label, double value, ValueChanged<double> onChanged) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(128, 128, 128, 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xA6000000))),
          const SizedBox(height: 15),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: Colors.lightGreen,
              inactiveTrackColor: Colors.grey.shade200,
              trackHeight: 8,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
              thumbColor: Colors.lightGreen,
              overlayColor: Colors.lightGreen.withAlpha((0.2 * 255).round()),
              showValueIndicator: ShowValueIndicator.never,
            ),
            child: Slider(
              value: value,
              min: 0,
              max: 100,
              divisions: 5,
              onChanged: onChanged,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:
              List.generate(6, (i) => Text('$i', style: const TextStyle(fontSize: 12, color: Colors.grey))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackTextBox() {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(128, 128, 128, 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.translate('weekly_feedback'),
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xA6000000))),
          const SizedBox(height: 15),
          TextField(
            controller: _feedbackController,
            maxLines: 5,
            minLines: 3,
            decoration: InputDecoration(
              hintText: l10n.translate('any_thoughts'),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.lightGreen, width: 2)),
              contentPadding: const EdgeInsets.all(12),
            ),
            keyboardType: TextInputType.multiline,
          ),
        ],
      ),
    );
  }
}