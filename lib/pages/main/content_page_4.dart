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
  static const String _lastFeedbackSyncDateKey = 'last_feedback_sync_date';

  // Slider keys
  static const String _energyKey = 'feedback_energy';
  static const String _satisfactionKey = 'feedback_satisfaction';
  static const String _happinessKey = 'feedback_happiness';
  static const String _proudKey = 'feedback_proud';
  static const String _busyKey = 'feedback_busy';
  static const String _feedbackTextKey = 'feedback_text';

  Timer? _weeklyTimer;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _initPrefsAndLoad();
    _feedbackController.addListener(_updateFeedbackText);

    // 🔄 Periodic weekly check every minute
    _weeklyTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
      await _checkAndSyncFeedback();
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
      _prefs.setString(_feedbackTextKey, newText);
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
    await _loadSliderValues();
    await _loadFeedbackText();
    await _checkAndSyncFeedback(); // Immediately check if a week ended
    if (mounted) setState(() {});
  }

  Future<void> _loadCreatedAt() async {
    final storedCreatedAt = _prefs.getString(_createdAtStorageKey);
    if (storedCreatedAt != null) {
      final ts = int.tryParse(storedCreatedAt);
      if (ts != null && ts > 0) {
        final fullDate = DateTime.fromMillisecondsSinceEpoch(ts);
        _createdAt = DateTime(fullDate.year, fullDate.month, fullDate.day);
      }
    }
  }

  Future<void> _loadSliderValues() async {
    setState(() {
      energy = _prefs.getDouble(_energyKey) ?? 0;
      satisfaction = _prefs.getDouble(_satisfactionKey) ?? 0;
      happiness = _prefs.getDouble(_happinessKey) ?? 0;
      proud = _prefs.getDouble(_proudKey) ?? 0;
      busy = _prefs.getDouble(_busyKey) ?? 0;
    });
  }

  Future<void> _loadFeedbackText() async {
    final text = _prefs.getString(_feedbackTextKey) ?? "";
    setState(() {
      feedbackText = text;
      _feedbackController.text = text;
    });
  }

  // ---------------- Weekly Logic ----------------
  int _calculateWeekNumber(DateTime startDate) {
    final today = DateTime.now();
    final daysSinceStart = DateTime(today.year, today.month, today.day)
        .difference(startDate)
        .inDays;
    final weekIndex = (daysSinceStart / 7).floor();
    return (weekIndex % 4) + 1;
  }

  DateTime _calculateNextWeekStart(DateTime startDate) {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final weekIndex = (startOfToday.difference(startDate).inDays / 7).floor();
    return startDate.add(Duration(days: (weekIndex + 1) * 7));
  }

  Future<void> _checkAndSyncFeedback() async {
    if (_createdAt == null) return;

    final nextWeekStart = _calculateNextWeekStart(_createdAt!);
    final now = DateTime.now();

    // Only sync if the week ended
    if (now.isAfter(nextWeekStart)) {
      final weekNumberToSync = _calculateWeekNumber(
        _createdAt!.add(
            Duration(days: ((now.difference(_createdAt!).inDays / 7).floor() - 1) * 7)),
      );

      try {
        await _api.updateWeeklyFeedback(
          weekNumber: weekNumberToSync,
          energyLevels: energy,
          satisfaction: satisfaction,
          happiness: happiness,
          proudOfAchievements: proud,
          howBusy: busy,
          feedbackText: feedbackText,
        );

        await _resetLocalFeedback();

        await _prefs.setString(
            _lastFeedbackSyncDateKey, now.toIso8601String());

        _showCompletionNotification(weekNumberToSync);

        if (mounted) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  '${l10n.translate('feedback_saved')} $weekNumberToSync ${l10n.translate('saved_and_reset')}')));
        }
      } catch (e) {
        if (mounted) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  '${l10n.translate('failed_to_sync')} ${e.toString()} ${l10n.translate('local_data_retained')}')));
        }
      }
    }
  }

  Future<void> _resetLocalFeedback() async {
    await _prefs.setDouble(_energyKey, 0);
    await _prefs.setDouble(_satisfactionKey, 0);
    await _prefs.setDouble(_happinessKey, 0);
    await _prefs.setDouble(_proudKey, 0);
    await _prefs.setDouble(_busyKey, 0);
    await _prefs.setString(_feedbackTextKey, "");
    await _loadSliderValues();
    await _loadFeedbackText();
  }

  // ---------------- Slider Handlers ----------------
  void _updateEnergy(double v) {
    setState(() => energy = v);
    _prefs.setDouble(_energyKey, v);
  }

  void _updateSatisfaction(double v) {
    setState(() => satisfaction = v);
    _prefs.setDouble(_satisfactionKey, v);
  }

  void _updateHappiness(double v) {
    setState(() => happiness = v);
    _prefs.setDouble(_happinessKey, v);
  }

  void _updateProud(double v) {
    setState(() => proud = v);
    _prefs.setDouble(_proudKey, v);
  }

  void _updateBusy(double v) {
    setState(() => busy = v);
    _prefs.setDouble(_busyKey, v);
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
              overlayColor: Colors.lightGreen.withOpacity(0.2),
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