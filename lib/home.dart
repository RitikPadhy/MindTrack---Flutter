import 'package:flutter/material.dart';
import 'pages/page1.dart'; // Read About
import 'pages/page2.dart'; // Profile
import 'pages/page3.dart'; // Schedule
import 'pages/page4.dart'; // Weekly Feedback
import 'pages/page5.dart'; // Achievements

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Default to Schedule page (index 2)
  int _selectedIndex = 2;

  final List<Widget> _pages = const [
    Page1(), // Read About
    Page2(), // Profile
    Page3(), // Schedule
    Page4(), // Weekly Feedback
    Page5(), // Achievements
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.menu_book), label: 'Read'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Schedule'),
          BottomNavigationBarItem(
              icon: Icon(Icons.feedback), label: 'Feedback'),
          BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events), label: 'Achievements'),
        ],
      ),
    );
  }
}