import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mind_track/widgets/schedule_item.dart';
import 'package:mind_track/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../services/api_service.dart';

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
  // Local state for the current day's checked boxes.
  // Key format: "$dateKey-$scheduleIndex-$taskIndex-$boxIndex"
  final Map<String, bool> _checkedState = {};
  late SharedPreferences _prefs;

  List<Map<String, dynamic>> _scheduleData = [];
  String _userGender = 'female'; // Added with a default value

  static const String _storageKey = 'checked_schedule_state';
  static const String _lastAccessDateKey = 'last_access_date';

  String _getDateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String _generateBoxKey(int scheduleIndex, int taskIndex, int boxIndex) {
    final dateStr = _getDateKey(_selectedDay);
    return "$dateStr-$scheduleIndex-$taskIndex-$boxIndex";
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // List of 17 time slots from 6:00 AM to 11:00 PM (17 hours)
  final List<String> times = [
    "6:00 AM - 7:00 AM", "7:00 AM - 8:00 AM", "8:00 AM - 9:00 AM",
    "9:00 AM - 10:00 AM", "10:00 AM - 11:00 AM", "11:00 AM - 12:00 PM",
    "12:00 PM - 1:00 PM", "1:00 PM - 2:00 PM", "2:00 PM - 3:00 PM",
    "3:00 PM - 4:00 PM", "4:00 PM - 5:00 PM", "5:00 PM - 6:00 PM",
    "6:00 PM - 7:00 PM", "7:00 PM - 8:00 PM", "8:00 PM - 9:00 PM",
    "9:00 PM - 10:00 PM",
    "10:00 PM - 11:00 PM", // Index 16
  ];

  // --- Core Initialization and Loading ---

  @override
  void initState() {
    super.initState();
    _initPrefsAndLoad();
  }

  Future<void> _initPrefsAndLoad() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadUserProfile(); // Load gender from local storage
    await _loadDataForSelectedDay();
  }

  // Only reads the user gender from SharedPreferences (local storage)
  Future<void> _loadUserProfile() async {
    const defaultGender = 'female';

    // Note: The key is 'gender' here based on the API Service logic
    final storedGender = _prefs.getString('gender');

    if (storedGender != null) {
      final finalGender = (storedGender.toLowerCase() == 'male' || storedGender.toLowerCase() == 'female')
          ? storedGender.toLowerCase()
          : defaultGender;
      if (mounted) {
        setState(() {
          _userGender = finalGender;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _userGender = defaultGender;
        });
      }
    }
    debugPrint("DEBUG: Loaded gender from local storage (or default): $_userGender");
  }

  // Main logic to decide data source (Local or API)
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
    Map<String, dynamic>? apiData;

    try {
      // Always fetch tasks from API to get the latest updates
      debugPrint("DEBUG: Fetching data from API for $selectedDateKey");
      apiData = await _api.getDayRoutine(selectedDateKey);
      debugPrint("DEBUG: Successfully fetched data from API for $selectedDateKey");
      
      // Update Schedule Data (The 'tasks' array from the API)
      if (apiData.containsKey('tasks') && apiData['tasks'] is List) {
        _scheduleData = (apiData['tasks'] as List).cast<Map<String, dynamic>>();
        debugPrint("DEBUG: Loaded ${_scheduleData.length} task items from API");
        
        // Debug: Print the first few items to see the structure
        if (_scheduleData.isNotEmpty) {
          debugPrint("DEBUG: First task item structure: ${_scheduleData[0]}");
          if (_scheduleData.length > 1) {
            debugPrint("DEBUG: Second task item structure: ${_scheduleData[1]}");
          }
        }
      } else {
        debugPrint("WARNING: API response missing 'tasks' key or invalid format");
        _scheduleData = [];
      }

      if (_isSameDay(_selectedDay, today)) {
        // --- CASE 1: CURRENT DAY (Load checked state from local storage with midnight sync check) ---
        debugPrint("DEBUG: Loading LOCAL checked state for $selectedDateKey");
        await _loadLocalCheckedState(selectedDateKey);
      } else {
        // --- CASE 2: NON-CURRENT DAY (Load checked state from API routine data) ---
        debugPrint("DEBUG: Loading API checked state for $selectedDateKey");
        _loadCheckedStateFromApiData(selectedDateKey, apiData);
      }
    } catch (e) {
      debugPrint("ERROR: Failed to load data for $selectedDateKey: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading schedule for $selectedDateKey: ${e.toString()}')),
        );
      }
      // Fallback to local storage for tasks if API fails
      await _loadTasksFromLocalStorage();
      _scheduleData = _scheduleData.isNotEmpty ? _scheduleData : [];
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Fallback to load tasks from local storage
  Future<void> _loadTasksFromLocalStorage() async {
    final scheduleJsonString = _prefs.getString(ApiService.scheduleStorageKey);
    if (scheduleJsonString != null) {
      try {
        _scheduleData = (jsonDecode(scheduleJsonString) as List).cast<Map<String, dynamic>>();
        debugPrint("DEBUG: Fallback: Loaded tasks from local storage");
      } catch (e) {
        debugPrint("ERROR: Failed to parse local schedule data: $e");
        _scheduleData = [];
      }
    } else {
      _scheduleData = [];
    }
  }

  // Helper to load checked state from local storage (for current day)
  Future<void> _loadLocalCheckedState(String dateKey) async {
    // 1. Midnight cleanup and sync check
    final savedDateString = _prefs.getString(_lastAccessDateKey);
    final todayString = _getDateKey(DateTime.now());

    // CRITICAL: Midnight Check and Synchronization (only happens on Day 1 when transitioning to Day 2)
    if (savedDateString != todayString && savedDateString != null) {

      debugPrint("DEBUG: Midnight sync triggered. Saved date: $savedDateString, Today: $todayString");

      // Load the checked state for the previous day from local storage one last time
      final jsonString = _prefs.getString(_storageKey);
      if (jsonString != null) {
        // Must use Map<String, dynamic> here because SharedPreferences stores dynamic/string values
        final Map<String, dynamic> previousDayCheckedState = Map<String, dynamic>.from(jsonDecode(jsonString));

        try {
          // A. TRANSFORM the local i-j-k state into the API's granular HH:MM status map
          final Map<String, Map<String, bool>> hourSlotsStatus = _transformCheckedStateToGranular(
            savedDateString,
            previousDayCheckedState,
          );

          // B. SAVE GRANULAR COMPLETION TO SERVER BEFORE CLEANSING
          if (hourSlotsStatus.isNotEmpty) {
            await _api.saveDayCompletionGranular(
              date: savedDateString,
              hourSlotsStatus: hourSlotsStatus,
            );
            debugPrint("DEBUG: Saved granular completion data for $savedDateString successfully.");
          } else {
            debugPrint("DEBUG: No checked tasks found for $savedDateString. Skipping API save.");
          }

        } catch (e) {
          // Log or handle error if saving fails (e.g., API is unreachable)
          debugPrint("ERROR: Failed to save granular completion for $savedDateString: $e");
        }
      }
      // -----------------------------------------------------------------

      // C. Midnight Cleanup (Clear local state ONLY AFTER API CALL)
      await _prefs.remove(_storageKey);
      _checkedState.clear();
      debugPrint("DEBUG: Local checked state cleared.");
    }

    // 2. Load the checked state for the currently selected day (which is 'today')
    final jsonString = _prefs.getString(_storageKey);
    if (jsonString != null) {
      final Map<String, dynamic> loadedMap = Map<String, dynamic>.from(jsonDecode(jsonString));
      loadedMap.forEach((key, value) {
        if (key.startsWith(dateKey)) {
          _checkedState[key] = value is bool ? value : false;
        }
      });
      debugPrint("DEBUG: Loaded checked state from local storage for $dateKey");
    }

    // 3. Final step: update last access date
    await _prefs.setString(_lastAccessDateKey, todayString);
  }

  // Helper to load checked state from API routine data (for non-current day)
  // Uses the already-fetched API data to avoid duplicate API calls
  void _loadCheckedStateFromApiData(String dateKey, Map<String, dynamic> apiData) {
    _checkedState.clear();
    final Map<String, dynamic> routineData = apiData['routine'] ?? {};

    routineData.forEach((hour, hourData) {
      final slots = hourData['slots'] as Map<String, dynamic>;

      // Map 15-min slots to the 4 boxes (k=0, 1, 2, 3)
      final List<String> slotMinutes = ['00', '15', '30', '45'];

      // Get the schedule index (i) from the time string (e.g., 06:00 -> 0)
      final int? scheduleIndex = int.tryParse(hour.substring(0, 2));
      if (scheduleIndex == null) return;
      final int index = scheduleIndex - 6;

      if (index >= 0 && index < 17) {
        for (int k = 0; k < 4; k++) {
          // The slot time from the API is HH:MM
          final slotTime = hour.substring(0, 3) + slotMinutes[k];
          final isFilled = slots[slotTime]?['filled'] ?? false;

          if (isFilled) {
            // If a slot is marked as 'filled' in the API, we mark the *first task's* box (j=0) as checked
            // as we don't have task-specific completion history here.
            final key = "$dateKey-$index-0-$k";
            _checkedState[key] = true;
          }
        }
      }
    });

    debugPrint("DEBUG: Loaded checked state from API for $dateKey");
  }

  // --- Transformation Logic ---
  // Transforms the local checkbox state (i-j-k) into the granular HH:MM map for the API
  Map<String, Map<String, bool>> _transformCheckedStateToGranular(
      String dateKey, Map<String, dynamic> previousDayCheckedState) {

    final Map<String, Map<String, bool>> hourSlotsStatus = {};

    // Base Time for index mapping (6:00 AM)
    final baseTime = DateTime(2000, 1, 1, 6, 0);

    // Iterate through all 17 hours (scheduleIndex i: 0 to 16)
    for (int i = 0; i < 17; i++) {
      final hourDt = baseTime.add(Duration(hours: i));
      final hourKey = DateFormat('HH:mm').format(hourDt); // "06:00", "07:00", etc.

      final hourMap = <String, bool>{};
      bool hourHasCompletion = false;

      // Iterate through the 4 slots (boxIndex k: 0, 1, 2, 3)
      for (int k = 0; k < 4; k++) {
        final slotDt = hourDt.add(Duration(minutes: k * 15));
        final slotKey = DateFormat('HH:mm').format(slotDt); // "06:00", "06:15", etc.

        // Check if ANY task (j=0 or j=1) in this hour (i) has this box (k) checked.
        bool isSlotFilled = false;

        // Check Task 0 (j=0)
        if (previousDayCheckedState.containsKey('$dateKey-$i-0-$k') && previousDayCheckedState['$dateKey-$i-0-$k'] == true) {
          isSlotFilled = true;
        }

        // Check Task 1 (j=1)
        if (!isSlotFilled && previousDayCheckedState.containsKey('$dateKey-$i-1-$k') && previousDayCheckedState['$dateKey-$i-1-$k'] == true) {
          isSlotFilled = true;
        }

        // The API expects 'status' based on the 'filled' state
        hourMap[slotKey] = isSlotFilled;
        if (isSlotFilled) {
          hourHasCompletion = true;
        }
      }

      // Only include hours that had at least one slot checked
      if (hourHasCompletion) {
        hourSlotsStatus[hourKey] = hourMap;
      }
    }
    return hourSlotsStatus;
  }
  // --- End Transformation Logic ---



  Future<void> _saveCheckedState() async {
    // Only save keys that belong to the current day
    final todayKey = _getDateKey(DateTime.now());
    final checkedForCurrentDay = Map.fromEntries(_checkedState.entries.where((e) {
      // Ensure we only save the current day's data
      return e.key.startsWith(todayKey);
    }));

    await _prefs.setString(_storageKey, jsonEncode(checkedForCurrentDay));

    final todayString = _getDateKey(DateTime.now());
    await _prefs.setString(_lastAccessDateKey, todayString);
  }

  // ------------------ Box Interaction ------------------

  void _handleBoxSelected(int scheduleIndex, int taskIndex, int boxIndex) {
    final today = DateTime.now();

    // RESTRICTION: Only allow interaction if selected day is today
    if (!_isSameDay(_selectedDay, today)) {
      return; // No popup, just do nothing
    }

    setState(() {
      _activeHourBox = scheduleIndex;
      final key = _generateBoxKey(scheduleIndex, taskIndex, boxIndex);

      _checkedState[key] = !(_checkedState[key] ?? false);

      _saveCheckedState();
    });
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
      if (_selectedDay.month != _currentDate.month) {
        _currentDate = _selectedDay;
      }
    });
    _loadDataForSelectedDay();
  }

  void _nextDay() {
    setState(() {
      _selectedDay = _selectedDay.add(const Duration(days: 1));
      if (_selectedDay.month != _currentDate.month) {
        _currentDate = _selectedDay;
      }
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
            setState(() {
              _selectedDay = day;
            });
            _loadDataForSelectedDay(); // CRITICAL: Call loader on tap
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

  // ------------------ Build UI ------------------
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
            // Header
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

            // Month Navigation
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

            // Weekday Bar
            Container(color: Colors.white, child: _buildDayWidgets()),

            const Divider(height: 1),

            // Schedule List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Opacity(
                // Dim the schedule for past/future days as they cannot be edited
                opacity: isToday ? 1.0 : 0.6,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  itemCount: _scheduleData.length,
                  itemBuilder: (context, i) {
                    // Handle both "tasks" and "items" keys (web interface uses "items", backend uses "tasks")
                    final taskData = _scheduleData[i];
                    List<String> taskList = [];
                    
                    if (taskData.containsKey("tasks")) {
                      // Backend format: {"tasks": ["task1", "task2"]}
                      final tasks = taskData["tasks"];
                      if (tasks is List) {
                        taskList = tasks.map((t) => t.toString()).toList().cast<String>();
                      }
                    } else if (taskData.containsKey("items")) {
                      // Web interface format: {"items": [{"title": "task1", "category": "..."}, ...]}
                      final items = taskData["items"];
                      if (items is List) {
                        taskList = items.map((item) {
                          if (item is Map) {
                            return (item["title"] ?? item.toString()) as String;
                          }
                          return item.toString();
                        }).toList().cast<String>();
                      }
                    }

                    // Do not render if the task list is empty
                    if (taskList.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return ScheduleItem(
                      time: times[i],
                      tasks: taskList,
                      isActive: _activeHourBox == i,
                      onBoxSelected: (taskIdx, boxIdx) =>
                          _handleBoxSelected(i, taskIdx, boxIdx),
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