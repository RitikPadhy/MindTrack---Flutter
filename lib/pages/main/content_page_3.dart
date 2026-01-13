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

  static const String _storageKey = 'checked_schedule_state';

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
    await _loadUserProfile();
    await _loadDataForSelectedDay();
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

    try {
      final apiData = await _api.getDayRoutine(selectedDateKey);

      if (apiData.containsKey('tasks') && apiData['tasks'] is List) {
        _scheduleData = (apiData['tasks'] as List).cast<Map<String, dynamic>>();
      } else {
        _scheduleData = [];
      }

      if (_isSameDay(_selectedDay, today)) {
        await _loadLocalCheckedState(selectedDateKey);
      } else {
        _loadCheckedStateFromApiData(selectedDateKey, apiData);
      }
    } catch (e) {
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
    final jsonString = _prefs.getString(_storageKey);
    if (jsonString != null) {
      final Map<String, dynamic> loadedMap = Map<String, dynamic>.from(jsonDecode(jsonString));
      loadedMap.forEach((key, value) {
        if (key.startsWith(dateKey)) {
          _checkedState[key] = value is bool ? value : false;
        }
      });
    }
  }

  void _loadCheckedStateFromApiData(String dateKey, Map<String, dynamic> apiData) {
    _checkedState.clear();
    final Map<String, dynamic> routineData = apiData['routine'] ?? {};
    final slotMinutes = ['00', '15', '30', '45'];

    routineData.forEach((hour, hourData) {
      final slots = hourData['slots'] as Map<String, dynamic>;
      final int? scheduleIndex = int.tryParse(hour.substring(0, 2));
      if (scheduleIndex == null) return;
      final int index = scheduleIndex - 6;

      if (index >= 0 && index < 17) {
        for (int k = 0; k < 4; k++) {
          final slotTime = hour.substring(0, 3) + slotMinutes[k];
          final isFilled = slots[slotTime]?['filled'] ?? false;
          if (isFilled) {
            final key = "$dateKey-$index-0-$k";
            _checkedState[key] = true;
          }
        }
      }
    });
  }

  Future<void> _saveCheckedState() async {
    await _prefs.setString(_storageKey, jsonEncode(_checkedState));
  }

  void _handleBoxSelected(int scheduleIndex, int taskIndex, int boxIndex) async {
    final today = DateTime.now();
    if (!_isSameDay(_selectedDay, today)) return;

    setState(() {
      _activeHourBox = scheduleIndex;

      final dateKey = _getDateKey(_selectedDay);
      final key = _generateBoxKey(scheduleIndex, taskIndex, boxIndex);

      // Toggle the clicked box
      final currentValue = _checkedState[key] ?? false;
      _checkedState[key] = !currentValue;

      // If it is now checked, uncheck same slot for other tasks in this hour
      if (_checkedState[key] == true) {
        final taskCount = _scheduleData[scheduleIndex]['tasks']?.length ?? 1;
        for (int t = 0; t < taskCount; t++) {
          if (t == taskIndex) continue; // skip current task
          final otherKey = _generateBoxKey(scheduleIndex, t, boxIndex);
          _checkedState[otherKey] = false;
        }
      }
    });

    await _saveCheckedState();
  }

  // ------------------ Robust Midnight Watcher ------------------
  void _startMidnightWatcher() {
    _midnightTimer?.cancel();
    _midnightTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
      final now = DateTime.now();
      final keys = _checkedState.keys.toList();

      // Detect keys from previous days
      final prevDayKeys = keys.where((k) => !k.startsWith(_getDateKey(now))).toList();

      if (prevDayKeys.isNotEmpty) {
        final prevDay = prevDayKeys.first.split('-')[0];
        final Map<String, dynamic> prevDayState = {
          for (var k in prevDayKeys) k: _checkedState[k]
        };

        try {
          final hourSlotsStatus = _transformCheckedStateToGranular(prevDay, prevDayState);
          if (hourSlotsStatus.isNotEmpty) {
            await _api.saveDayCompletionGranular(
              date: prevDay,
              hourSlotsStatus: hourSlotsStatus,
            );
            debugPrint("DEBUG: Pushed previous day data for $prevDay");
          }
        } catch (e) {
          debugPrint("ERROR: Failed to push previous day data: $e");
        }

        // Clear only previous day keys after successful update
        for (var k in prevDayKeys) {
          _checkedState.remove(k);
        }
        await _prefs.setString(_storageKey, jsonEncode(_checkedState));
      }
    });
  }

  // ------------------ Transform Checked State ------------------
  Map<String, Map<String, bool>> _transformCheckedStateToGranular(
      String dateKey, Map<String, dynamic> checkedState) {
    final Map<String, Map<String, bool>> hourSlotsStatus = {};
    final baseTime = DateTime(2000, 1, 1, 6, 0);

    for (int i = 0; i < 17; i++) {
      final hourDt = baseTime.add(Duration(hours: i));
      final hourKey = DateFormat('HH:mm').format(hourDt);
      final hourMap = <String, bool>{};
      bool hourHasCompletion = false;

      for (int k = 0; k < 4; k++) {
        final slotDt = hourDt.add(Duration(minutes: k * 15));
        final slotKey = DateFormat('HH:mm').format(slotDt);

        bool isSlotFilled = checkedState['$dateKey-$i-0-$k'] == true ||
            checkedState['$dateKey-$i-1-$k'] == true;

        hourMap[slotKey] = isSlotFilled;
        if (isSlotFilled) hourHasCompletion = true;
      }

      if (hourHasCompletion) hourSlotsStatus[hourKey] = hourMap;
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