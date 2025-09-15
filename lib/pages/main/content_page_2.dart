import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';

class ContentPage2 extends StatelessWidget {
  const ContentPage2({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure system nav bar stays consistent
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.grey[200], // light grey
        systemNavigationBarIconBrightness: Brightness.dark, // dark icons
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.redAccent.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Track Your Progress',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 30), // Increased spacing

              // Day/Week/Month Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildProgressButton('DAY', false),
                  _buildProgressButton('WEEK', false),
                  _buildProgressButton('MONTH', true),
                ],
              ),

              const SizedBox(height: 70), // Increased spacing

              // Pie Chart
              SizedBox(
                height: 250,
                child: PieChart(
                  PieChartData(
                    sections: _getSections(),
                    sectionsSpace: 0, // Set sectionsSpace to 0 to remove gaps
                    centerSpaceRadius: 70,
                  ),
                ),
              ),

              const SizedBox(height: 60), // Increased spacing

              // Information Box
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'You have spent more time on productive tasks than usual',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const Spacer(),
              const SizedBox(height: 20), // Padding at the bottom
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressButton(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.redAccent.shade100 : Colors.white,
        border: Border.all(color: Colors.redAccent.shade100),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isSelected ? Colors.white : Colors.black54,
        ),
      ),
    );
  }

  List<PieChartSectionData> _getSections() {
    return [
      PieChartSectionData(
        color: Colors.lightGreen.shade300,
        value: 12.5,
        title: 'self care\n12.5%',
        radius: 100,
        titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
      ),
      PieChartSectionData(
        color: Colors.blueGrey.shade700,
        value: 44.4,
        title: 'productivity\n44.4%',
        radius: 100,
        titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
      ),
      PieChartSectionData(
        color: Colors.blue.shade800,
        value: 16.7,
        title: 'leisure and hobbies\n16.7%',
        radius: 100,
        titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
      ),
      PieChartSectionData(
        color: Colors.cyan.shade400,
        value: 13.7,
        title: 'Home tasks\n13.7%',
        radius: 100,
        titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
      ),
      PieChartSectionData(
        color: Colors.orange.shade300,
        value: 12.4,
        title: 'social and community\n12.4%',
        radius: 100,
        titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    ];
  }
}