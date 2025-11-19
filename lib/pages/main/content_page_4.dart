import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../services/api_service.dart';

// Global instance for the plugin (common practice for simplicity)
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

class ContentPage4 extends StatefulWidget {
  const ContentPage4({super.key});

  @override
  State<ContentPage4> createState() => _ContentPage4State();
}

class _ContentPage4State extends State<ContentPage4> {
  // 🎚️ Sliders’ state values (0–100)
  double energy = 0;
  double satisfaction = 0;
  double happiness = 0;
  double proud = 0;
  double busy = 0;

  // ✅ NEW: Text feedback state and controller
  String feedbackText = "";
  final TextEditingController _feedbackController = TextEditingController();

  // 🗓️ State & Storage Keys
  DateTime? _createdAt;
  late SharedPreferences _prefs;
  final ApiService _api = ApiService();

  static const String _createdAtStorageKey = 'user_created_at';
  static const String _lastFeedbackSyncDateKey = 'last_feedback_sync_date';

  // 🔑 Keys for the five slider values
  static const String _energyKey = 'feedback_energy';
  static const String _satisfactionKey = 'feedback_satisfaction';
  static const String _happinessKey = 'feedback_happiness';
  static const String _proudKey = 'feedback_proud';
  static const String _busyKey = 'feedback_busy';
  // ✅ NEW: Key for the feedback text
  static const String _feedbackTextKey = 'feedback_text';


  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _initPrefsAndLoad();
    // ✅ NEW: Add listener to update state when text field changes
    _feedbackController.addListener(_updateFeedbackText);
  }

  // ✅ NEW: Dispose the controller and remove the listener
  @override
  void dispose() {
    _feedbackController.removeListener(_updateFeedbackText);
    _feedbackController.dispose();
    super.dispose();
  }

  // ✅ NEW: Listener function
  void _updateFeedbackText() {
    final newText = _feedbackController.text;
    if (feedbackText != newText) {
      setState(() {
        feedbackText = newText;
      });
      // Immediately save the text input
      _saveFeedbackText(newText);
    }
  }


  // --- Notification Initialization (omitted for brevity, no changes here) ---

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // 🔔 NEW: Method to show the notification (omitted for brevity, no changes here)
  Future<void> _showCompletionNotification(int weekNumber) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'weekly_feedback_channel', // Channel ID
      'Weekly Feedback Notifications', // Channel Name
      channelDescription: 'Notifications for successful weekly feedback submissions.',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      'Feedback Complete! 📝', // Title
      'Thanks for your feedback! Your data for Week $weekNumber has been successfully saved and your new week has begun.', // Body
      platformChannelSpecifics,
      payload: 'feedback_synced',
    );
  }

  // --- Core Initialization and Loading ---

  Future<void> _initPrefsAndLoad() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadCreatedAt();
    await _checkAndSyncFeedback(); // CRITICAL: Check for rollover and sync before loading
    await _loadSliderValues();
    await _loadFeedbackText(); // ✅ NEW: Load feedback text
    // After loading, force UI update to show correct week range
    if(mounted) setState(() {});
  }

  // 🚀 Method to load the createdAt timestamp (omitted for brevity, no changes here)
  Future<void> _loadCreatedAt() async {
    final storedCreatedAtString = _prefs.getString(_createdAtStorageKey);
    DateTime? loadedDate;

    if (storedCreatedAtString != null) {
      final timestamp = int.tryParse(storedCreatedAtString);

      if (timestamp != null && timestamp > 0) {
        final fullDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
        // Normalize loaded date to the start of the day (00:00:00)
        loadedDate = DateTime(fullDate.year, fullDate.month, fullDate.day);
      }
    }
    _createdAt = loadedDate;
  }

  // 💾 Method to load slider values from SharedPreferences (omitted for brevity, no changes here)
  Future<void> _loadSliderValues() async {
    final double loadedEnergy = _prefs.getDouble(_energyKey) ?? 0.0;
    final double loadedSatisfaction = _prefs.getDouble(_satisfactionKey) ?? 0.0;
    final double loadedHappiness = _prefs.getDouble(_happinessKey) ?? 0.0;
    final double loadedProud = _prefs.getDouble(_proudKey) ?? 0.0;
    final double loadedBusy = _prefs.getDouble(_busyKey) ?? 0.0;

    if (mounted) {
      setState(() {
        energy = loadedEnergy;
        satisfaction = loadedSatisfaction;
        happiness = loadedHappiness;
        proud = loadedProud;
        busy = loadedBusy;
      });
    }
  }

  // ✅ NEW: Load feedback text
  Future<void> _loadFeedbackText() async {
    final String loadedText = _prefs.getString(_feedbackTextKey) ?? "";
    if (mounted) {
      setState(() {
        feedbackText = loadedText;
        _feedbackController.text = loadedText; // Set the controller's text
      });
    }
  }

  // 📝 Method to save a single slider value (omitted for brevity, no changes here)
  Future<void> _saveSliderValue(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  // ✅ NEW: Method to save feedback text
  Future<void> _saveFeedbackText(String value) async {
    await _prefs.setString(_feedbackTextKey, value);
  }


  // --- Weekly Sync and Reset Logic (omitted for brevity, no changes to Week calculation) ---

  int _calculateWeekNumber(DateTime startDate) {
    final DateTime today = DateTime.now();
    final DateTime startOfDayToday = DateTime(today.year, today.month, today.day);

    final int daysSinceStart = startOfDayToday.difference(startDate).inDays;

    final int weekIndex = (daysSinceStart / 7).floor();

    return (weekIndex % 4) + 1;
  }

  DateTime _calculateNextResetTime(DateTime startDate) {
    final DateTime today = DateTime.now();
    final DateTime startOfToday = DateTime(today.year, today.month, today.day);

    final int daysSinceStart = startOfToday.difference(startDate).inDays;

    final int currentWeekIndex = (daysSinceStart / 7).floor();

    final DateTime nextWeekStartDate = startDate.add(Duration(days: (currentWeekIndex + 1) * 7));

    return nextWeekStartDate;
  }

  // CRITICAL: Checks if the week has ended and performs sync/reset
  Future<void> _checkAndSyncFeedback() async {
    if (_createdAt == null) return;

    final DateTime nextResetTime = _calculateNextResetTime(_createdAt!);
    final DateTime now = DateTime.now();

    // Check if we have passed the weekly midnight reset time
    if (now.isAfter(nextResetTime)) {

      final DateTime lastWeekStartDate = _createdAt!.add(Duration(days: ((now.difference(_createdAt!).inDays / 7).floor() - 1) * 7));
      final int weekNumberToSync = _calculateWeekNumber(lastWeekStartDate);

      try {
        // 1. CALL API (Save current slider values for the week that just ended)
        // ✅ UPDATED: Include feedbackText
        await _api.updateWeeklyFeedback(
          weekNumber: weekNumberToSync,
          energyLevels: energy,
          satisfaction: satisfaction,
          happiness: happiness,
          proudOfAchievements: proud,
          howBusy: busy,
          feedbackText: feedbackText, // ✅ NEW PARAMETER
        );

        // 2. RESET LOCAL DATA
        await _resetLocalFeedback();

        // 3. Update sync date marker
        await _prefs.setString(_lastFeedbackSyncDateKey, now.toIso8601String());

        if (!mounted) return; // ✅ Ensure safe before using context

        // Re-load to update UI with reset values
        await _loadSliderValues();
        await _loadFeedbackText(); // ✅ NEW: Reload (which sets to empty string/resets controller)

        _showCompletionNotification(weekNumberToSync);

        // ✅ Only show SnackBar if widget still exists
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Weekly feedback for Week $weekNumberToSync saved and reset.')),
          );
        }

      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Warning: Failed to sync feedback: ${e.toString()}. Local data retained.')),
          );
        }
      }
    }
  }

  // 📝 Resets the 5 slider values back to 0 in SharedPreferences
  // ✅ UPDATED: Include feedback text reset
  Future<void> _resetLocalFeedback() async {
    await _prefs.setDouble(_energyKey, 0.0);
    await _prefs.setDouble(_satisfactionKey, 0.0);
    await _prefs.setDouble(_happinessKey, 0.0);
    await _prefs.setDouble(_proudKey, 0.0);
    await _prefs.setDouble(_busyKey, 0.0);
    await _prefs.setString(_feedbackTextKey, ""); // ✅ NEW: Reset feedback text
  }

  // --- Slider Handlers (omitted for brevity, no changes here) ---

  void _updateEnergy(double v) {
    setState(() => energy = v);
    _saveSliderValue(_energyKey, v);
  }

  void _updateSatisfaction(double v) {
    setState(() => satisfaction = v);
    _saveSliderValue(_satisfactionKey, v);
  }

  void _updateHappiness(double v) {
    setState(() => happiness = v);
    _saveSliderValue(_happinessKey, v);
  }

  void _updateProud(double v) {
    setState(() => proud = v);
    _saveSliderValue(_proudKey, v);
  }

  void _updateBusy(double v) {
    setState(() => busy = v);
    _saveSliderValue(_busyKey, v);
  }

  // --- Build Method (omitted for brevity, only the children list is relevant) ---

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String weekRange;
    String creationDate;

    // ... (omitted week calculation logic) ...
    if (_createdAt != null) {
      final DateTime startDate = _createdAt!;

      final DateTime today = DateTime(now.year, now.month, now.day);
      final int daysSinceStart = today.difference(startDate).inDays;

      final int currentWeekIndex = (daysSinceStart / 7).floor();

      // The start and end dates for the current week block
      final DateTime weekStartDate = startDate.add(Duration(days: currentWeekIndex * 7));
      final DateTime weekEndDate = weekStartDate.add(const Duration(days: 6));

      weekRange = '${DateFormat('d MMMM').format(weekStartDate)} – ${DateFormat('d MMMM').format(weekEndDate)}';

      creationDate = 'Member Since: ${DateFormat('MMMM d, yyyy').format(_createdAt!)} | Week ${_calculateWeekNumber(startDate)}';


    } else {
      weekRange = 'Loading week range...';
      creationDate = 'Loading member status...';
    }


    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Container
              Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF9FE2BF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Weekly Feedback',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Creation Date Display
              Text(
                creationDate,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),

              // Dynamic Week Range (Calculated relative to _createdAt)
              Text(
                weekRange,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xA6000000),
                ),
              ),

              const SizedBox(height: 16),

              // 🎚️ Interactive Progress Bars
              _buildInteractiveBar('Energy Levels', energy, _updateEnergy),
              _buildInteractiveBar('Satisfaction', satisfaction, _updateSatisfaction),
              _buildInteractiveBar('Happiness', happiness, _updateHappiness),
              _buildInteractiveBar('Proud of my achievements', proud, _updateProud),
              _buildInteractiveBar('How busy you felt?', busy, _updateBusy),

              const SizedBox(height: 16),

              // ✅ NEW: Feedback Text Box
              _buildFeedbackTextBox(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // 🧱 Reusable widget for each feedback slider (omitted for brevity, no changes here)
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
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xA6000000),
            ),
          ),
          const SizedBox(height: 15),

          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: Colors.lightGreen,
              inactiveTrackColor: Colors.grey.shade200,
              trackHeight: 8,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
              thumbColor: Colors.lightGreen,
              overlayColor: Colors.lightGreen.withValues(alpha: 0.2),

              // 🚫 Disable the floating value label
              showValueIndicator: ShowValueIndicator.never,
            ),
            child: Slider(
              value: value,
              min: 0,
              max: 100,
              divisions: 5, // 0–5 steps
              onChanged: onChanged,
            ),
          ),

          // ✅ Number labels below slider (0–5)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                6,
                    (i) => Text(
                  '$i',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ NEW: Widget for the text input box
  Widget _buildFeedbackTextBox() {
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
          const Text(
            'Weekly Feedback',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xA6000000),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _feedbackController,
            maxLines: 5,
            minLines: 3,
            decoration: InputDecoration(
              hintText: 'Any thoughts or comments about this week?',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.lightGreen, width: 2),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
            keyboardType: TextInputType.multiline,
          ),
        ],
      ),
    );
  }
}