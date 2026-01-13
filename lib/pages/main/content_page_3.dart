import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mind_track/widgets/schedule_item.dart';
import 'package:mind_track/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mind_track/services/api_service.dart';

class ContentPage3 extends StatefulWidget {
  const ContentPage3({super.key});

  @override
  ContentPage3State createState() => ContentPage3State();
}

class ContentPage3State extends State<ContentPage3> {
  DateTime _currentDate = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  final ApiService _api = ApiService();
  bool _isLoading = false;

  int? _activeHourBox;

  // Local state for the current day's checked boxes
  final Map<String, bool> _checkedState = {};
  late SharedPreferences _prefs;

  List<Map<String, dynamic>> _scheduleData = [];
  String _userGender = 'female';

  String _getStorageKey(DateTime date) => 'checked_schedule_state_${_getDateKey(date)}';

  Timer? _midnightTimer;

  final List<String> times = [
    "6:00 AM - 7:00 AM", "7:00 AM - 8:00 AM", "8:00 AM - 9:00 AM",
    "9:00 AM - 10:00 AM", "10:00 AM - 11:00 AM", "11:00 AM - 12:00 PM",
    "12:00 PM - 1:00 PM", "1:00 PM - 2:00 PM", "2:00 PM - 3:00 PM",
    "3:00 PM - 4:00 PM", "4:00 PM - 5:00 PM", "5:00 PM - 6:00 PM",
    "6:00 PM - 7:00 PM", "7:00 PM - 8:00 PM", "8:00 PM - 9:00 PM",
    "9:00 PM - 10:00 PM", "10:00 PM - 11:00 PM"
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initPrefsAndLoad();
      _startMidnightWatcher();
    });
  }

  @override
  void dispose() {
    _midnightTimer?.cancel();
    super.dispose();
  }

  String _getDateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  String _generateBoxKey(int scheduleIndex, int taskIndex, int boxIndex) {
    final dateStr = _getDateKey(_selectedDay);
    return "$dateStr-$scheduleIndex-$taskIndex-$boxIndex";
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> _initPrefsAndLoad() async {
    _prefs = await SharedPreferences.getInstance();
    final jsonString = _prefs.getString(ApiService.scheduleStorageKey);
    if (jsonString != null) {
      _scheduleData = (jsonDecode(jsonString) as List).cast<Map<String, dynamic>>();
    }
    await _pushAllPendingDays();
    await _loadUserProfile();
    await _loadDataForSelectedDay();
  }

  Future<void> _pushAllPendingDays() async {
    final allKeys = _prefs
        .getKeys()
        .where((k) => k.startsWith('checked_schedule_state_'))
        .toList();

    final todayKey = _getDateKey(DateTime.now());

    for (final key in allKeys) {
      final datePart = key.replaceFirst('checked_schedule_state_', '');

      // Never push today
      if (datePart == todayKey) continue;

      final jsonString = _prefs.getString(key);
      if (jsonString == null) continue;

      final Map<String, dynamic> state =
      Map<String, dynamic>.from(jsonDecode(jsonString));

      if (state.isEmpty) continue;

      try {
        final hourSlotsStatus =
        _transformCheckedStateToGranular(datePart, state);

        if (hourSlotsStatus.isNotEmpty) {
          await _api.saveDayCompletionGranular(
            date: datePart,
            hourSlotsStatus: hourSlotsStatus,
          );

          // Mark as synced only after success
          await _prefs.remove(key);
          debugPrint("DEBUG: Catch-up pushed $datePart");
        }
      } catch (e) {
        debugPrint("ERROR: Failed to push $datePart: $e");
        // Keep key so it can retry next time
      }
    }
  }

  Future<void> _loadUserProfile() async {
    const defaultGender = 'female';
    final storedGender = _prefs.getString('gender');
    _userGender = (storedGender != null &&
        (storedGender.toLowerCase() == 'male' || storedGender.toLowerCase() == 'female'))
        ? storedGender.toLowerCase()
        : defaultGender;

    if (mounted) setState(() {});
  }

  Future<void> _loadDataForSelectedDay() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _activeHourBox = null;
      _checkedState.clear();
      _scheduleData.clear();
    });

    final selectedDateKey = _getDateKey(_selectedDay);
    final today = DateTime.now();
    final bool isToday = _isSameDay(_selectedDay, today);

    try {
      if (isToday) {
        // ------------------- TODAY -------------------
        // Load schedule & checkedState from SharedPreferences only
        final jsonString = _prefs.getString(ApiService.scheduleStorageKey);
        if (jsonString != null) {
          _scheduleData = (jsonDecode(jsonString) as List).cast<Map<String, dynamic>>();
        }

        await _loadLocalCheckedState(selectedDateKey);
      } else {
        // ------------------- PAST DAYS -------------------
        // Fetch from API
        final apiData = await _api.getDayRoutine(selectedDateKey);

        if (apiData.containsKey('tasks') && apiData['tasks'] is List) {
          _scheduleData = (apiData['tasks'] as List).cast<Map<String, dynamic>>();
        } else {
          _scheduleData = [];
        }

        _loadCheckedStateFromApiData(selectedDateKey, apiData);
      }
    } catch (e) {
      debugPrint("ERROR loading schedule: $e");

      // Fallback: try SharedPreferences
      final jsonString = _prefs.getString(ApiService.scheduleStorageKey);
      if (jsonString != null) {
        _scheduleData = (jsonDecode(jsonString) as List).cast<Map<String, dynamic>>();
      } else {
        _scheduleData = [];
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadLocalCheckedState(String dateKey) async {
    final jsonString = _prefs.getString(_getStorageKey(_selectedDay));
    if (jsonString != null) {
      final Map<String, dynamic> loadedMap = Map<String, dynamic>.from(jsonDecode(jsonString));
      _checkedState.clear();
      loadedMap.forEach((key, value) {
        _checkedState[key] = value is bool ? value : false;
      });
    }
  }

  void _loadCheckedStateFromApiData(String dateKey, Map<String, dynamic> apiData) {
    _checkedState.clear();

    // API returns "routine", not "routines"
    final Map<String, dynamic> dayRoutines =
    Map<String, dynamic>.from(apiData['routine'] ?? {});

    dayRoutines.forEach((hour, hourData) {
      if (hourData is! Map || hourData['slots'] == null) return;

      final Map<String, dynamic> slots =
      Map<String, dynamic>.from(hourData['slots']);
      final int hourInt = int.tryParse(hour.split(":")[0]) ?? 0;
      final int scheduleIndex = hourInt - 6; // 06:00 -> 0

      if (scheduleIndex < 0 || scheduleIndex >= _scheduleData.length) return;

      slots.forEach((slotTime, slotData) {
        if (slotData is! Map) return;

        final bool isFilled = slotData['filled'] == true;
        final int? taskIndex =
        slotData['taskIndex'] is int ? slotData['taskIndex'] : null;

        if (isFilled && taskIndex != null) {
          final key =
              "$dateKey-$scheduleIndex-$taskIndex-${_minuteIndex(slotTime)}";
          _checkedState[key] = true;
        }
      });
    });

    if (mounted) setState(() {});
  }

  /// Converts slot string "06:15" to index 0..3
  int _minuteIndex(String slotTime) {
    final minute = int.tryParse(slotTime.split(":")[1]) ?? 0;
    switch (minute) {
      case 0:
        return 0;
      case 15:
        return 1;
      case 30:
        return 2;
      case 45:
        return 3;
      default:
        return 0;
    }
  }

  Future<void> _saveCheckedState() async {
    final key = _getStorageKey(_selectedDay);
    await _prefs.setString(key, jsonEncode(_checkedState));

    // Optional: keep only last 30 days to avoid bloat
    final allKeys = _prefs.getKeys().where((k) => k.startsWith('checked_schedule_state_')).toList();
    if (allKeys.length > 30) {
      allKeys.sort();
      for (var i = 0; i < allKeys.length - 30; i++) {
        await _prefs.remove(allKeys[i]);
      }
    }
  }

  void _handleBoxSelected(int scheduleIndex, int taskIndex, int boxIndex) async {
    final today = DateTime.now();
    if (!_isSameDay(_selectedDay, today)) return;

    setState(() {
      _activeHourBox = scheduleIndex;
      final key = _generateBoxKey(scheduleIndex, taskIndex, boxIndex);

      final bool isNowChecked = !(_checkedState[key] ?? false);

      if (isNowChecked) {
        // Clear THIS SLOT (boxIndex) for all other tasks in this hour
        final tasks = _scheduleData[scheduleIndex]['tasks'] ??
            _scheduleData[scheduleIndex]['items'] ??
            [];
        final taskCount = tasks.length;

        for (int t = 0; t < taskCount; t++) {
          if (t == taskIndex) continue;
          final otherKey = _generateBoxKey(scheduleIndex, t, boxIndex);
          _checkedState[otherKey] = false;
        }

        _checkedState[key] = true;
      } else {
        // Just uncheck this box
        _checkedState[key] = false;
      }
    });

    await _saveCheckedState();
  }

  // ------------------ Robust Midnight Watcher ------------------
  void _startMidnightWatcher() {
    _midnightTimer?.cancel();

    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final duration = tomorrow.difference(now);

    _midnightTimer = Timer(duration, () async {
      debugPrint("DEBUG: Midnight reached, pushing data...");

      // Push yesterday's data
      await _pushPreviousDayData();

      // Reschedule for next midnight
      _startMidnightWatcher();
    });
  }

  Future<void> _pushPreviousDayData() async {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final key = _getStorageKey(yesterday);
    final jsonString = _prefs.getString(key);
    if (jsonString == null) return;

    final Map<String, dynamic> prevDayState = Map<String, dynamic>.from(jsonDecode(jsonString));
    if (prevDayState.isEmpty) return;

    try {
      final hourSlotsStatus = _transformCheckedStateToGranular(_getDateKey(yesterday), prevDayState);
      if (hourSlotsStatus.isNotEmpty) {
        await _api.saveDayCompletionGranular(
          date: _getDateKey(yesterday),
          hourSlotsStatus: hourSlotsStatus,
        );
        await _prefs.remove(key); // remove only after successful push
        debugPrint("DEBUG: Pushed current day data for ${_getDateKey(yesterday)}");
      }
    } catch (e) {
      debugPrint("ERROR: Failed to push previous day data: $e");
    }
  }

  // ------------------ Transform Checked State ------------------
  Map<String, Map<String, Map<String, dynamic>>> _transformCheckedStateToGranular(
      String dateKey, Map<String, dynamic> checkedState) {

    final Map<String, Map<String, Map<String, dynamic>>> hourSlotsStatus = {};
    final baseTime = DateTime(2000, 1, 1, 6, 0); // Start at 6:00 AM

    for (int i = 0; i < _scheduleData.length; i++) {
      final hourDt = baseTime.add(Duration(hours: i));
      final hourKey = DateFormat('HH:mm').format(hourDt);

      final taskList = _scheduleData[i]['tasks'] ?? _scheduleData[i]['items'] ?? [];
      final Map<String, Map<String, dynamic>> hourMap = {};

      for (int k = 0; k < 4; k++) { // 4 boxes (0, 15, 30, 45 mins)
        final slotDt = hourDt.add(Duration(minutes: k * 15));
        final slotKey = DateFormat('HH:mm').format(slotDt);

        int? filledTaskIndex;
        for (int t = 0; t < taskList.length; t++) {
          if (checkedState['$dateKey-$i-$t-$k'] == true) {
            filledTaskIndex = t;
            break;
          }
        }

        if (filledTaskIndex != null) {
          // Flat structure: slots -> "06:15" -> {filled: true, taskIndex: 0}
          hourMap[slotKey] = {
            "filled": true,
            "taskIndex": filledTaskIndex,
          };
        }
      }

      if (hourMap.isNotEmpty) {
        hourSlotsStatus[hourKey] = {
          "slots": hourMap,
        };
      }
    }

    return hourSlotsStatus;
  }

  // ------------------ Date Navigation ------------------
  void _previousMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
      _selectedDay = _currentDate;
    });
    _loadDataForSelectedDay();
  }

  void _nextMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
      _selectedDay = _currentDate;
    });
    _loadDataForSelectedDay();
  }

  void _previousDay() {
    setState(() {
      _selectedDay = _selectedDay.subtract(const Duration(days: 1));
      if (_selectedDay.month != _currentDate.month) _currentDate = _selectedDay;
    });
    _loadDataForSelectedDay();
  }

  void _nextDay() {
    setState(() {
      _selectedDay = _selectedDay.add(const Duration(days: 1));
      if (_selectedDay.month != _currentDate.month) _currentDate = _selectedDay;
    });
    _loadDataForSelectedDay();
  }

  Widget _buildDayWidgets() {
    final List<Widget> dayWidgets = [];

    dayWidgets.add(
      IconButton(
        icon: const Icon(Icons.chevron_left, size: 24, color: Colors.black54),
        onPressed: _previousDay,
      ),
    );

    for (int i = 0; i < 5; i++) {
      final DateTime day = _selectedDay.add(Duration(days: i - 2));
      final String dayName = DateFormat('E').format(day);
      final String dayNumber = day.day.toString();
      final bool isSelected = _isSameDay(day, _selectedDay);

      dayWidgets.add(
        GestureDetector(
          onTap: () {
            setState(() => _selectedDay = day);
            _loadDataForSelectedDay();
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: isSelected ? Colors.lightBlue[50] : null,
            ),
            child: Text(
              "$dayName\n$dayNumber",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.blue : Colors.black,
              ),
            ),
          ),
        ),
      );
    }

    dayWidgets.add(
      IconButton(
        icon: const Icon(Icons.chevron_right, size: 24, color: Colors.black54),
        onPressed: _nextDay,
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: dayWidgets,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String monthYear = DateFormat('MMMM, yyyy').format(_currentDate).toUpperCase();
    final isToday = _isSameDay(_selectedDay, DateTime.now());

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              color: const Color(0xFF9FE2BF),
              child: Center(
                child: Text(
                  AppLocalizations.of(context).translate('daily_schedule'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: const Color(0xFFFFFDE7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 28, color: Colors.black54),
                    onPressed: _previousMonth,
                  ),
                  Text(
                    monthYear,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 28, color: Colors.black54),
                    onPressed: _nextMonth,
                  ),
                ],
              ),
            ),
            Container(color: Colors.white, child: _buildDayWidgets()),
            const Divider(height: 1),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Opacity(
                opacity: isToday ? 1.0 : 0.6,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  itemCount: _scheduleData.length,
                  itemBuilder: (context, i) {
                    final taskData = _scheduleData[i];
                    List<String> taskList = [];

                    if (taskData.containsKey("tasks")) {
                      final tasks = taskData["tasks"];
                      if (tasks is List) {
                        taskList = tasks.map((t) => t.toString()).toList();
                      }
                    } else if (taskData.containsKey("items")) {
                      final items = taskData["items"];
                      if (items is List) {
                        taskList = items.map((item) {
                          if (item is Map) return (item["title"] ?? item.toString()) as String;
                          return item.toString();
                        }).toList();
                      }
                    }

                    if (taskList.isEmpty) return const SizedBox.shrink();

                    return ScheduleItem(
                      time: times[i],
                      tasks: taskList,
                      isActive: _activeHourBox == i,
                      onBoxSelected: (taskIdx, boxIdx) => _handleBoxSelected(i, taskIdx, boxIdx),
                      checkedState: _checkedState,
                      scheduleIndex: i,
                      dateKey: _getDateKey(_selectedDay),
                      userGender: _userGender,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}