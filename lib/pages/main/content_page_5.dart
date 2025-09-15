import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ContentPage5 extends StatelessWidget {
  const ContentPage5({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure system nav bar stays consistent
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.grey[200],
        systemNavigationBarIconBrightness: Brightness.dark,
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
              // Header Container
              Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.redAccent.shade100,
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
              const SizedBox(height: 20),

              // Date Range
              const Text(
                'August 1 - August 7',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              // Progress Bars
              _buildProgressBar('Energy Levels', 0.8),
              _buildProgressBar('Satisfaction', 0.6),
              _buildProgressBar('Happiness', 0.4),
              _buildProgressBar('Proud of my achievements', 0.7),
              _buildProgressBar('How busy you felt ?', 0.7),

              const Spacer(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to build each progress bar
  Widget _buildProgressBar(String label, double value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 12,
              backgroundColor: Colors.white,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.lightGreen),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to build the footer icons
  Widget _buildFooterIcon(IconData icon, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.deepOrange.shade300 : Colors.transparent,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Icon(
        icon,
        size: 30,
        color: isSelected ? Colors.white : Colors.black54,
      ),
    );
  }
}