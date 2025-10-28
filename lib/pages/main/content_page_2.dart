import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ContentPage2 extends StatelessWidget {
  const ContentPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
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
                  color: Colors.green.shade900,
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

              const SizedBox(height: 30),

              // Day/Week/Month Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildProgressButton('DAY', false),
                  _buildProgressButton('WEEK', false),
                  _buildProgressButton('MONTH', true),
                ],
              ),

              const SizedBox(height: 70),

              // Pie Chart
              SizedBox(
                height: 250,
                child: PieChart(
                  PieChartData(
                    sections: _getSections(),
                    sectionsSpace: 4,
                    centerSpaceRadius: 70,
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),

              const SizedBox(height: 60),

              // Information Box
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromRGBO(128, 128, 128, 0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade100),
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
              const SizedBox(height: 20),
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
        color: isSelected ? Colors.green.shade900 : Colors.white,
        border: Border.all(color: Colors.green.shade100),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(128, 128, 128, 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
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

  // --- Green gradient pie sections (50 → 300) ---
  List<PieChartSectionData> _getSections() {
    final titles = [
      'Self\nCare',
      'Productivity',
      'Leisure\n& Hobbies',
      'Home\nTasks',
      'Social\n& Community',
    ];

    final values = [12.5, 44.4, 16.7, 13.7, 12.4];

    // Color range: from light green → deeper green
    const startColor = Color(0xFF6BBF7A); // medium-dark green
    const endColor = Color(0xFF3E8E41);   // slightly lighter than 0xFF2E7D32

    Color interpolateColor(double t) {
      // Linear interpolation between start and end colors
      int r = (startColor.r + (endColor.r - startColor.r) * t).round();
      int g = (startColor.g + (endColor.g - startColor.g) * t).round();
      int b = (startColor.b + (endColor.b - startColor.b) * t).round();
      return Color.fromRGBO(r, g, b, 1);
    }

    return List.generate(values.length, (i) {
      final double t = values.length == 1 ? 0.0 : i / (values.length - 1);
      final color = interpolateColor(t);

      return PieChartSectionData(
        color: color,
        value: values[i],
        title: titles[i],
        radius: 105,
        titlePositionPercentageOffset: 0.55,
        titleStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      );
    });
  }
}