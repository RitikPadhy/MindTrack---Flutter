import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mind_track/widgets/schedule_item.dart';

class ContentPage3 extends StatefulWidget {
  const ContentPage3({super.key});

  @override
  ContentPage3State createState() => ContentPage3State();
}

class ContentPage3State extends State<ContentPage3> {
  DateTime _currentDate = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  // Track which hour block is active
  int? _activeHourBox;
  final Map<String, bool> _checkedState = {}; // ✅ each box unique per hour-task-box

  // ✅ Updated JSON-like data
  final List<Map<String, dynamic>> scheduleData = [
    {"tasks": ["Prayer"]},
    {"tasks": ["Exercise", "Read newspapers"]},
    {"tasks": ["Fresh Up", "Breakfast"]},
    {"tasks": ["Class and Clinics"]},
    {"tasks": ["Class and Clinics"]},
    {"tasks": ["Class and Clinics"]},
    {"tasks": ["Lunch and Prayer"]},
    {"tasks": ["Class"]},
    {"tasks": ["Class"]},
    {"tasks": ["Fresh Up and Prayer"]},
    {"tasks": ["Watch Series"]},
    {"tasks": ["Study"]},
    {"tasks": ["Dinner"]},
    {"tasks": ["Call Parents"]},
    {"tasks": ["Prayer or Relax"]},
    {"tasks": ["Sleep"]},
  ];

  final List<String> times = [
    "6:00 AM - 7:00 AM",
    "7:00 AM - 8:00 AM",
    "8:00 AM - 9:00 AM",
    "9:00 AM - 10:00 AM",
    "10:00 AM - 11:00 AM",
    "11:00 AM - 12:00 PM",
    "12:00 PM - 1:00 PM",
    "1:00 PM - 2:00 PM",
    "2:00 PM - 3:00 PM",
    "3:00 PM - 4:00 PM",
    "4:00 PM - 5:00 PM",
    "5:00 PM - 6:00 PM",
    "6:00 PM - 7:00 PM",
    "7:00 PM - 8:00 PM",
    "8:00 PM - 9:00 PM",
    "9:00 PM - 10:00 PM",
  ];

  void _handleBoxSelected(int scheduleIndex, int taskIndex, int boxIndex) {
    setState(() {
      _activeHourBox = scheduleIndex;
      final key = "$scheduleIndex-$taskIndex-$boxIndex";
      _checkedState[key] = !(_checkedState[key] ?? false);
    });
  }

  // ------------------ Date Navigation ------------------

  void _previousMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
      _selectedDay = _currentDate;
    });
  }

  void _nextMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
      _selectedDay = _currentDate;
    });
  }

  void _previousDay() {
    setState(() {
      _selectedDay = _selectedDay.subtract(const Duration(days: 1));
      if (_selectedDay.month != _currentDate.month) {
        _currentDate = _selectedDay;
      }
    });
  }

  void _nextDay() {
    setState(() {
      _selectedDay = _selectedDay.add(const Duration(days: 1));
      if (_selectedDay.month != _currentDate.month) {
        _currentDate = _selectedDay;
      }
    });
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

      dayWidgets.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDay = day;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "$dayName\n$dayNumber",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: day.day == _selectedDay.day && day.month == _selectedDay.month
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: day.day == _selectedDay.day && day.month == _selectedDay.month
                    ? Colors.blue
                    : Colors.black,
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
              child: const Center(
                child: Text(
                  'Daily Schedule',
                  style: TextStyle(
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
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                itemCount: scheduleData.length,
                itemBuilder: (context, i) {
                  final taskList = List<String>.from(scheduleData[i]["tasks"]);
                  return ScheduleItem(
                    time: times[i],
                    tasks: taskList,
                    isActive: _activeHourBox == i,
                    onBoxSelected: (taskIdx, boxIdx) =>
                        _handleBoxSelected(i, taskIdx, boxIdx),
                    checkedState: _checkedState,
                    scheduleIndex: i,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}