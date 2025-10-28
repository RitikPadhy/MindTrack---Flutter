import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // ✅ for date formatting

class ContentPage4 extends StatefulWidget {
  const ContentPage4({super.key});

  @override
  State<ContentPage4> createState() => _ContentPage4State();
}

class _ContentPage4State extends State<ContentPage4> {
  // 🎚️ Sliders’ state values (0–100)
  double energy = 80;
  double satisfaction = 60;
  double happiness = 40;
  double proud = 70;
  double busy = 70;

  @override
  Widget build(BuildContext context) {
    // 🗓️ Get current week range (Monday → Sunday)
    DateTime now = DateTime.now();
    DateTime monday = now.subtract(Duration(days: now.weekday - 1));
    DateTime sunday = monday.add(const Duration(days: 6));

    // 📅 Format with full month names
    String weekRange;
    if (monday.month == sunday.month) {
      weekRange =
      '${DateFormat('d').format(monday)} – ${DateFormat('d MMMM').format(sunday)}';
    } else {
      weekRange =
      '${DateFormat('d MMMM').format(monday)} – ${DateFormat('d MMMM').format(sunday)}';
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Container
              Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade900,
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

              // Dynamic Week Range
              Text(
                weekRange,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // 🎚️ Interactive Progress Bars
              _buildInteractiveBar('Energy Levels', energy, (v) {
                setState(() => energy = v);
              }),
              _buildInteractiveBar('Satisfaction', satisfaction, (v) {
                setState(() => satisfaction = v);
              }),
              _buildInteractiveBar('Happiness', happiness, (v) {
                setState(() => happiness = v);
              }),
              _buildInteractiveBar('Proud of my achievements', proud, (v) {
                setState(() => proud = v);
              }),
              _buildInteractiveBar('How busy you felt?', busy, (v) {
                setState(() => busy = v);
              }),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // 🧱 Reusable widget for each feedback slider
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
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 15), // ⬅️ Increased spacing between label & bar

          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: Colors.lightGreen,
              inactiveTrackColor: Colors.grey.shade200,
              trackHeight: 8,
              thumbShape:
              const RoundSliderThumbShape(enabledThumbRadius: 0), // hide thumb
              overlayShape:
              const RoundSliderOverlayShape(overlayRadius: 0), // no overlay
              thumbColor: Colors.transparent,
              overlayColor: Colors.transparent,
            ),
            child: Slider(
              value: value,
              min: 0,
              max: 100,
              divisions: 100,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}