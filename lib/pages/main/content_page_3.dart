import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mind_track/widgets/schedule_item.dart';

class ContentPage3 extends StatefulWidget {
  const ContentPage3({super.key});

  @override
  ContentPage3State createState() => ContentPage3State(); // ✅ public state
}

class ContentPage3State extends State<ContentPage3> {
  DateTime _currentDate = DateTime.now();
  DateTime _selectedDay = DateTime.now();

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
      if (_selectedDay.day > 1) {
        _selectedDay = _selectedDay.subtract(const Duration(days: 1));
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

    // Previous Day Button
    dayWidgets.add(
      IconButton(
        icon: const Icon(Icons.chevron_left, size: 24, color: Colors.black54),
        onPressed: _previousDay,
      ),
    );

    // Build 5 day widgets
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
              color: day.day == _selectedDay.day && day.month == _selectedDay.month
                  ? Color.fromRGBO(33, 150, 243, 0.1)
                  : Colors.transparent,
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

    // Next Day Button
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              color: Colors.redAccent.shade100,
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

            // Week Days
            _buildDayWidgets(),

            const Divider(height: 1),

            // Scrollable Schedule Section
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                children: const [
                  ScheduleItem(
                    time: "10 AM - 11 AM",
                    title: "Self Care",
                    isDone: true,
                    hasExtra: true,
                  ),
                  ScheduleItem(
                    time: "11 AM - 12 PM",
                    title: "Cleaning the house",
                    isDone: false,
                    hasExtra: false,
                  ),
                  ScheduleItem(
                    time: "12 PM - 1 PM",
                    title: "Cleaning the house",
                    isDone: true,
                    hasExtra: false,
                  ),
                  ScheduleItem(
                    time: "2 PM - 3 PM",
                    title: "Playing",
                    isDone: true,
                    hasExtra: false,
                  ),
                  ScheduleItem(
                    time: "12 PM - 1 PM",
                    title: "Sleeping",
                    isDone: true,
                    hasExtra: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}